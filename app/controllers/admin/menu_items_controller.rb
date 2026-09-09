# frozen_string_literal: true

module Admin
  # Admin menu management (T5). Only admins may create, edit, or deactivate
  # menu items. Prices are entered in rupees (NPR) and stored as integer paisa
  # in price_cents. "Deactivate" soft-hides an item by flipping available to
  # false (FR-4: only available items are orderable) rather than deleting it,
  # because order_items restrict deletion of referenced items.
  class MenuItemsController < ApplicationController
    before_action :require_admin
    before_action :set_menu_item, only: %i[edit update deactivate]
    before_action :set_categories, only: %i[new create edit update]

    def index
      @menu_items = MenuItem.includes(:category).order(:name, :id)
    end

    def new
      @menu_item = MenuItem.new
    end

    def create
      @menu_item = MenuItem.new(menu_item_params)
      @menu_item.price_cents = rupees_to_cents(@menu_item.price_rupees)

      if @menu_item.save
        redirect_to admin_menu_items_path, notice: "Menu item created: #{@menu_item.name}."
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit; end

    def update
      @menu_item.assign_attributes(menu_item_params)
      @menu_item.price_cents = rupees_to_cents(@menu_item.price_rupees)

      if @menu_item.save
        redirect_to admin_menu_items_path, notice: "#{@menu_item.name} has been updated."
      else
        render :edit, status: :unprocessable_content
      end
    end

    def deactivate
      was_available = @menu_item.available?

      if @menu_item.update(available: false)
        if was_available
          redirect_to admin_menu_items_path, notice: "#{@menu_item.name} is no longer available."
        else
          redirect_to admin_menu_items_path, notice: "#{@menu_item.name} is already unavailable."
        end
      else
        alert = "Could not deactivate #{@menu_item.name}."
        alert += " #{@menu_item.errors.full_messages.to_sentence}" if @menu_item.errors.any?
        redirect_to admin_menu_items_path, alert: alert
      end
    end

    private

    def set_menu_item
      @menu_item = MenuItem.find(params[:id])
    end

    def set_categories
      @categories = Category.order(:position, :name)
    end

    def menu_item_params
      params.require(:menu_item).permit(:name, :description, :category_id, :available, :redeemable, :price_rupees)
    end

    # 150.50 NPR is entered in rupees but stored as 15_050 paisa. A blank or
    # non-numeric value becomes nil so the price_cents presence validation
    # reports the failure instead of silently storing zero.
    def rupees_to_cents(rupees)
      return nil if rupees.blank?

      (BigDecimal(rupees.to_s) * 100).round
    rescue ArgumentError
      nil
    end
  end
end