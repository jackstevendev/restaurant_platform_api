# Clear existing data to ensure idempotency when running seeds
puts "Cleaning database..."
Payment.destroy_all
OrderItem.destroy_all
Order.destroy_all
InventoryItem.destroy_all
Product.destroy_all
Restaurant.destroy_all
Customer.destroy_all

puts "Creating Restaurants and Specific Products..."

restaurants_data = [
  {
    name: "The Golden Bistro",
    address: "123 Main Street, New York, NY 10001",
    products: [
      { name: "Prime Ribeye Steak", price: 34.99 },
      { name: "French Onion Soup", price: 9.50 },
      { name: "Duck Confit", price: 28.00 },
      { name: "Escargot de Bourgogne", price: 14.00 },
      { name: "Lobster Bisque", price: 12.50 },
      { name: "Crème Brûlée", price: 8.50 },
      { name: "Truffle Fries", price: 7.50 },
      { name: "Filet Mignon", price: 38.00 },
      { name: "House Caesar Salad", price: 10.50 },
      { name: "Chocolate Fondant", price: 9.00 }
    ]
  },
  {
    name: "Ocean Breeze Seafood",
    address: "456 Ocean Drive, Miami, FL 33139",
    products: [
      { name: "Grilled Salmon Fillet", price: 24.99 },
      { name: "Oysters on the Half Shell", price: 18.00 },
      { name: "Lobster Roll", price: 22.50 },
      { name: "Fried Calamari", price: 13.00 },
      { name: "Fish & Chips", price: 16.50 },
      { name: "Clam Chowder", price: 9.99 },
      { name: "Garlic Butter Shrimp", price: 19.50 },
      { name: "Seared Ahi Tuna", price: 26.00 },
      { name: "Crab Cakes", price: 21.00 },
      { name: "Key Lime Pie", price: 7.99 }
    ]
  },
  {
    name: "Sabor Italiano",
    address: "789 Little Italy Way, Chicago, IL 60607",
    products: [
      { name: "Margherita Pizza", price: 14.99 },
      { name: "Spaghetti Carbonara", price: 16.50 },
      { name: "Fettuccine Alfredo", price: 15.00 },
      { name: "Lasagna Bolognese", price: 17.99 },
      { name: "Chicken Parmesan", price: 19.00 },
      { name: "Penne Alla Vodka", price: 16.00 },
      { name: "Tiramisu", price: 8.50 },
      { name: "Garlic Bread Sticks", price: 5.00 },
      { name: "Caprese Salad", price: 11.50 },
      { name: "Minestrone Soup", price: 7.99 }
    ]
  },
  {
    name: "Sakura Ramen & Sushi",
    address: "321 Cherry Blossom Ln, San Francisco, CA 94102",
    products: [
      { name: "Tonkotsu Ramen", price: 15.99 },
      { name: "Spicy Tuna Roll", price: 13.50 },
      { name: "California Roll", price: 10.50 },
      { name: "Salmon Nigiri (4pcs)", price: 12.00 },
      { name: "Gyoza Dumplings", price: 8.50 },
      { name: "Miso Soup", price: 4.00 },
      { name: "Edamame", price: 5.00 },
      { name: "Tempura Shrimp", price: 11.99 },
      { name: "Dragon Roll", price: 16.50 },
      { name: "Matcha Ice Cream", price: 5.50 }
    ]
  },
  {
    name: "Smokehouse BBQ",
    address: "654 Pitmaster Ave, Austin, TX 78701",
    products: [
      { name: "Smoked Beef Brisket", price: 22.99 },
      { name: "Pulled Pork Sandwich", price: 12.50 },
      { name: "St. Louis Ribs (Half Rack)", price: 19.99 },
      { name: "BBQ Chicken Half", price: 15.50 },
      { name: "Mac & Cheese", price: 6.50 },
      { name: "Cornbread Muffins", price: 4.50 },
      { name: "Baked Beans", price: 4.00 },
      { name: "Coleslaw", price: 3.50 },
      { name: "Smoked Sausage", price: 11.00 },
      { name: "Pecan Pie", price: 7.00 }
    ]
  }
]

restaurants_data.each do |data|
  restaurant = Restaurant.create!(
    name: data[:name],
    address: data[:address]
  )

  data[:products].each do |prod_attrs|
    product = restaurant.products.create!(
      name: prod_attrs[:name],
      price: prod_attrs[:price],
      active: true
    )

    InventoryItem.create!(
      product: product,
      quantity: rand(15..100),
      minimum_stock: 5
    )
  end
end

puts "Created #{Restaurant.count} restaurants with 10 unique products and inventory items each."

puts "Creating Customers..."
customers_data = [
  { name: "John Doe", email: "john.doe@example.com", phone: "+1-555-0101" },
  { name: "Jane Smith", email: "jane.smith@example.com", phone: "+1-555-0102" },
  { name: "Alex Johnson", email: "alex.johnson@example.com", phone: "+1-555-0103" },
  { name: "Emily Davis", email: "emily.davis@example.com", phone: "+1-555-0104" },
  { name: "Michael Brown", email: "michael.brown@example.com", phone: "+1-555-0105" }
]

customers = customers_data.map do |attrs|
  Customer.create!(attrs)
end

puts "Created #{customers.count} customers."
puts "Seeds loaded successfully!"
