# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Settings.roles.all.each do |role|
  Role.create(name: role) unless Role.find_by_name(role).present?
end

admin_role = Role.find_by_name(Settings.roles.admin)

demo_admin = User.find_by_email("admin@ecommerce.demo") || User.new(
  email: "admin@ecommerce.demo",
  name: "Joe Doe",
  role: admin_role,
  password: "password",
  password_confirmation: "password"
)

demo_admin.save if demo_admin.valid?

customer_role = Role.find_by_name(Settings.roles.customer)

demo_user = User.find_by_email("customer@ecommerce.demo") || User.new(
  email: "customer@ecommerce.demo",
  name: "Eva Portman",
  role: customer_role,
  password: "password",
  password_confirmation: "password"
)

demo_user.save if demo_user.valid?

currency = Currency.find_by_name("NTD") || Currency.create(name: "USD", symbol: "$")

classification = Classification.find_by_name("Phone Card") || Classification.create(name: "Phone Card", description: "Prepaid phone SIM card.")

product = Product.find_by_name("AT&T 4G Phone Card") || Product.create(
  name: "Kindle E-readers",
  description: "The best devices for reading, period.",
  properties: {
    connection: %w(3G WiFi),
    version: %w(addon addfree),
    model: %W(kindle paperwhite voyage oasis),
    color: %W(black white)
  },
  available_on: Time.current,
  classification: classification
)

variant = Variant.first || Variant.create(
  price: 7999,
  properties: {
    connection: "WiFi",
    version: "addon",
    model: "kindle",
    color: "black"
  },
  currency: currency,
  product: product
)

variant_2 =
  if Variant.count == 2
    Variant.last
  elsif Variant.count == 1
    Variant.create(
      price: 9999,
      properties: {
        connection: "WiFi",
        version: "addfree",
        model: "kindle",
        color: "black"
      },
      currency: currency,
      product: product
    )
  end

order_1 = Order.create!(
  order_number: "#{Time.current.to_i.to_s.rjust(20, "0")}#{SecureRandom.random_number(999).to_s.rjust(3, "0")}",
  billing_contact_info:
  {
    attn_name: "Joe Doe",
    email: "joe_doe@email.com",
    phone: "0921345678",
    address: "Some where in Taiwan",
    zipcode: "220"
  },
  shipping_contact_info:
  {
    attn_name: "Joe Doe",
    email: "joe_doe@email.com",
    phone: "0921345678",
    address: "Some where in Taiwan",
    zipcode: "220"
  },
  line_item_total: 25997,
  promo_total: 25997,
  status: Settings.order.status.payment_pending,
  currency: currency,
  user: demo_user
)

LineItem.create(
  unit_price: 7999,
  quantity: 2,
  lock_inventory: false,
  line_item_total: 15998,
  variant: variant,
  currency: currency,
  order: order_1
)

LineItem.create(
  unit_price: 9999,
  quantity: 1,
  lock_inventory: false,
  line_item_total: 9999,
  variant: variant_2,
  currency: currency,
  order: order_1
)

order_2 = Order.create!(
  order_number: "#{Time.current.to_i.to_s.rjust(20, "0")}#{SecureRandom.random_number(999).to_s.rjust(3, "0")}",
  billing_contact_info:
  {
    attn_name: "Joe Doe",
    email: "joe_doe@email.com",
    phone: "0921345678",
    address: "Some where in Taiwan",
    zipcode: "220"
  },
  shipping_contact_info:
  {
    attn_name: "Joe Doe",
    email: "joe_doe@email.com",
    phone: "0921345678",
    address: "Some where in Taiwan",
    zipcode: "220"
  },
  line_item_total: 0,
  promo_total: 0,
  status: Settings.order.status.shopping,
  currency: currency,
  user: demo_user
)
