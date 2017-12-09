# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Permission.create(name: "read")
Permission.create(name: "update")
Permission.create(name: "share")

user1 = User.create(email: Faker::Internet.email, password: "password")
user2 = User.create(email: Faker::Internet.email, password: "password")

random_note1 = user1.created_notes.create(body: Faker::Lorem.paragraph(2))
random_note2 = user2.created_notes.create(body: Faker::Lorem.paragraph(2))
