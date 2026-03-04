# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# db/seeds.rb

puts "--- Nettoyage de la base de données ---"
Result.destroy_all
Message.destroy_all
Chat.destroy_all
User.destroy_all

puts "--- Création de l'utilisateur de test ---"
test_user = User.create!(
  email: "test@careerclarity.ai",
  password: "password123",
  password_confirmation: "password123"
)

puts "--- Création des 3 scénarios de test ---"

# SCÉNARIO 1 : Reconversion professionnelle
chat_1 = Chat.create!(
  user: test_user,
  persona: "Salarié en poste",
  title: "Reconversion Web Design"
)

Message.create!([
  { chat: chat_1, role: "user", content: "Je suis comptable depuis 10 ans mais je veux devenir Web Designer. Par quoi commencer ?" },
  { chat: chat_1, role: "assistant", content: "C'est un beau projet ! Avez-vous déjà manipulé des outils comme Figma ou Canva ?" }
])

# SCÉNARIO 2 : Négociation de salaire
chat_2 = Chat.create!(
  user: test_user,
  persona: "Freelance",
  title: "Négociation TJM Grand Compte"
)

Message.create!([
  { chat: chat_2, role: "user", content: "Un client me propose une mission de 6 mois mais mon TJM habituel est trop élevé pour eux. Comment négocier ?" },
  { chat: chat_2, role: "assistant", content: "Dans ce cas, nous pouvons regarder du côté des avantages hors-tarif : télétravail total, matériel fourni ou horaires flexibles." }
])

# SCÉNARIO 3 : Recherche d'emploi (avec Roadmap déjà générée)
chat_3 = Chat.create!(
  user: test_user,
  persona: "Sans emploi",
  title: "Stratégie LinkedIn 2026"
)

Message.create!([
  { chat: chat_3, role: "user", content: "Mon profil LinkedIn ne reçoit aucune visite. Que dois-je changer ?" },
  { chat: chat_3, role: "assistant", content: "Il faut optimiser votre titre et votre résumé avec des mots-clés spécifiques à votre secteur." }
])

Result.create!(
  chat: chat_3,
  roadmap: "1. Optimiser le titre de profil.\n2. Publier un post par semaine.\n3. Contacter 5 recruteurs cibles."
)

puts "--- Seeding terminé avec succès ! ---"
puts "Identifiants : test@careerclarity.ai / password123"
