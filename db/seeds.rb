account = Account
  .create_with(email: "account@example.com")
  .first_or_create!

User
  .create_with(
    account: account,
    password: "password",
    password_confirmation: "password"
  )
  .find_or_create_by!(email: "user@example.com")
