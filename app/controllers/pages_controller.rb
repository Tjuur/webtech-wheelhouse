class PagesController < ApplicationController
  def home
  end

  def services
    @services = [
      { name: "Flat Tire Repair", price: 15 },
      { name: "Brake Adjustment", price: 20 },
      { name: "Gear Adjustment", price: 20 },
      { name: "Chain Replacement", price: 25 },
      { name: "Tube Replacement", price: 18 },
      { name: "Tire Replacement", price: 30 },
      { name: "Wheel Truing", price: 25 },
      { name: "Brake Pad Replacement", price: 30 },
      { name: "Cable Replacement", price: 25 },
      { name: "Drivetrain Cleaning", price: 35 },
      { name: "Basic Tune-Up", price: 50 },
      { name: "Full Tune-Up", price: 90 }
    ]
  end

  def visit
  end

  def about
  end
end