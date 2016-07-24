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

currency = Currency.find_by_name("NTD") || Currency.create(name: "NTD", symbol: "$")

classification = Classification.find_by_name("Phone Card") || Classification.create(name: "Phone Card", description: "Prepaid phone SIM card.")

product = Product.find_by_name("AT&T 4G Phone Card") || Product.create(
  name: "AT&T 4G Phone Card",
  description: "☆ AT&T預付卡(美國手機門號)，享用美國當地話費，以及手機在美國上網！/n☆ 美國AT&T是全球最大的電信公司，在美國有最大的訊號範圍/n☆ 已開卡，到達美國後，將美國SIM卡插入台灣三頻手機，即可立即使用!/n☆ 限掛寄出免運費，上班日13:00前付款當天寄出，最快隔日即可收到  急用請參考/n☆ 免費 iPhone 剪卡服務，限可通話的手機使用；平板電腦/iPad/行動分享器無法使用",
  properties: {
    color: %w(red black yellow),
    bandwidth: %w(1G 3G 5G)
  },
  available_on: Time.current,
  classification: classification
)

variant = Variant.first || Variant.create(
  price: 10000,
  properties: {
    color: "red",
    bandwidth: "5G"
  },
  currency: currency,
  product: product
)

variant_2 =
  if Variant.count == 2
    Variant.last
  elsif Variant.count == 1
    Variant.create(
      price: 10000,
      properties: {
        color: "red",
        bandwidth: "5G"
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
  line_item_total: 25000,
  promo_total: 24000,
  status: "待付款",
  currency: currency,
  user: demo_user
)

LineItem.create(
  unit_price: 10000,
  quantity: 2,
  lock_inventory: false,
  line_item_total: 20000,
  variant: variant,
  currency: currency,
  order: order_1
)

LineItem.create(
  unit_price: 5000,
  quantity: 1,
  lock_inventory: false,
  line_item_total: 5000,
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
  status: "購物中",
  currency: currency,
  user: demo_user
)
