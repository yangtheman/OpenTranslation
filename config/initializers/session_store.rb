# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
#ActionController::Base.session = {
#  :key         => '_openT_session',
#  :secret      => '827e65441c8206342131ca4fe4df4aa6a058fefd73d8bdf886365cd6f01388ab7839b2573539328cbb5235f590674cb3c0b02c4fbdfabf357359882249aa83c6'
#}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
ActionController::Base.session_store = :active_record_store
