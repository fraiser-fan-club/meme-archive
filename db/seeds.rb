# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Meme.create([{
  name: "Dennys",
  source_url: "https://www.youtube.com/watch?v=QBw4huCadBQ",
  start: 2,
  end: 6,
  private: false
},
{
  name: "All Woman Are Queens",
  source_url: "https://www.youtube.com/watch?v=IdyXKJ8NcNI",
  start: 0,
  end: 10,
  private: false
}
])