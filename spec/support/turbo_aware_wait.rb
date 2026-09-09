# Makes Capybara element clicks Turbo-aware and resilient to dropped clicks.
#
# Two distinct failure modes are handled:
#
# 1. Turbo render race. Turbo Drive navigates asynchronously: after a
#    link/form interaction the browser fetches the next page and swaps the
#    DOM in a separate render pass. Capybara's implicit waits only cover
#    element *presence*, not "Turbo has finished rendering", so a click
#    dispatched while a render is in flight (or on a node a render just
#    replaced) can be swallowed without raising -- the classic "click
#    eaten" system-spec flake (see hotwired/turbo#537).
#
#    Turbo marks an in-flight visit by setting `aria-busy` on <html>, and
#    preview swaps by setting `data-turbo-preview`. Waiting for both to be
#    absent before every click closes the race window without app changes.
#
# 2. Silently dropped coordinate clicks. chromedriver dispatches element
#    clicks at computed screen coordinates; under load (long suites,
#    renderer saturation) the click can land at stale coordinates and hit
#    nothing, producing no DOM event and no error (SeleniumHQ/selenium
#    #16345; mitigated further by --disable-smooth-scrolling). Turbo sets
#    `aria-busy` *synchronously* in the click handler for links and
#    submits, and opens the confirm() dialog synchronously for
#    data-confirm/data-turbo-confirm elements, so the absence of either
#    signal shortly after a native click means the click was almost
#    certainly dropped. The click is then retried as a JS-dispatched click
#    (arguments[0].click()), which bypasses coordinate hit-testing
#    entirely; Turbo handles both the navigation and data-confirm flows
#    client-side, so behavior is unchanged.
#
# Implementation notes:
# - All element attribute reads happen *before* the native click: after it,
#   the element may be replaced by a render, and an open confirm() dialog
#   makes ChromeDriver auto-dismiss the dialog when any other command
#   arrives.
# - Selenium's switch_to.alert merely instantiates an Alert object; the
#   actual round trip is the first method call (.text), which raises
#   NoSuchAlertError when no dialog is open.
# - window.confirm() blocks the renderer's main thread, so a retry click on
#   a confirm element must not run synchronously inside execute_script (the
#   driver call would never return while the dialog is open). Dispatching it
#   via setTimeout makes the script call return immediately.
module TurboAwareClick
  TURBO_BUSY_SELECTOR = "html[aria-busy], html[data-turbo-preview]"

  def click(*keys, **offset)
    unless session.driver.is_a?(Capybara::RackTest::Driver)
      session.assert_no_selector TURBO_BUSY_SELECTOR, visible: :all
      retryable = retryable_element?
      confirm = confirm_element?
      super
      retry_dropped_click(confirm) if retryable
    else
      super
    end
  end

  private

  def retryable_element?
    tag = native&.tag_name&.upcase

    %w[A BUTTON].include?(tag) ||
      (tag == "INPUT" && %w[SUBMIT BUTTON RESET].include?(native&.attribute("type")&.upcase))
  end

  def confirm_element?
    native&.attribute("data-turbo-confirm") || native&.attribute("data-confirm")
  end

  def retry_dropped_click(confirm)
    if confirm
      # A processed click leaves a confirm() dialog open; a dropped click
      # leaves nothing. When the native click worked, accept_confirm takes
      # over and handles the dialog.
      alert = alert_appeared?
      return nil if alert
      dispatch_js_click
    else
      # Turbo sets aria-busy synchronously when a link/form click starts a
      # visit; if nothing appeared within ~300ms, the click was dropped.
      busy = busy_appeared?
      return nil if busy
      dispatch_js_click
    end
  rescue Capybara::ExpectationNotMet, Selenium::WebDriver::Error::WebDriverError, Capybara::ElementNotFound
    # Busy/dialog appeared => click worked. Stale element (page changed) or
    # any other driver error => the native click already had its effect, or
    # there is nothing to retry. Carry on; the spec's next assertion waits.
    nil
  end

  def busy_appeared?
    session.has_selector?(TURBO_BUSY_SELECTOR, visible: :all, wait: 0.3)
  end

  def dispatch_js_click
    session.execute_script("setTimeout(() => arguments[0].click(), 0)", self)
  end

  def alert_appeared?
    deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + 0.5
    loop do
      session.driver.browser.switch_to.alert.text
      return true
    rescue Selenium::WebDriver::Error::NoSuchAlertError
      return false if Process.clock_gettime(Process::CLOCK_MONOTONIC) >= deadline

      sleep 0.05
    end
  end
end

module TurboAwareFill
  # Chromedriver intermittently drops send_keys keystrokes on
  # Turbo-navigated pages (no input event ever fires, and retrying keys
  # does not recover). Real keystrokes remain the primary path for
  # fidelity; when the value does not land we set it directly via the DOM,
  # which Turbo serializes identically for the form submission. Safe here
  # because this app's forms have no JS input listeners.
  def fill_in(locator = nil, with: nil, **options)
    el = find(:fillable_field, locator, **options)
    el.set(with)
    return el if el.value == with

    session.execute_script(<<~JS, el, with.to_s)
      arguments[0].value = arguments[1];
      arguments[0].dispatchEvent(new Event("input", { bubbles: true }));
      arguments[0].dispatchEvent(new Event("change", { bubbles: true }));
    JS
    el
  end
end

Capybara::Node::Element.prepend TurboAwareClick
Capybara::Node::Actions.prepend TurboAwareFill
