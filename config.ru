# This is only used in development, to have a shotgun-based
# reloading server. In production, the app is started by 
# Foreman using the local Procfile

require './app'

run VerboSnarferWebApp
