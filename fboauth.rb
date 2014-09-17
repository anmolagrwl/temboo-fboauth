# https://www.temboo.com/ruby/facebook-oauth

# Here we'll show you how to go through the Facebook OAuth process in Ruby, which lets any Facebook user log in to Facebook and grant your app access to their account. Our simple app logs users in and displays some info about their Facebook profile.


require 'sinatra'
require 'temboo'
require 'Library/Facebook'

# By default, Sinatra disables sessions. To keep things simple, we'll store
# values accessed across pages in global variables.
$temboo_session = TembooSession.new('anmol1771', 'SF', '8896dc9a19f94248884de4369dd9b50f')
$app_id = '657840067637421'
$app_secret = '43e14b0cbaad41b637db80ed3afc35ff'
$callback_id = '' # Leave this empty to start out.

# Landing page with a link to get the OAuth process started.
get '/' do
    'Log in with <a href="initialize">Facebook</a>.<br />'
end

get '/initialize' do
    oauth_init_choreo = Facebook::OAuth::InitializeOAuth.new($temboo_session)

    # Get an InputSet object for the choreo
    oauth_init_inputs = oauth_init_choreo.new_input_set()

    # Set inputs
    oauth_init_inputs.set_AppID($app_id)
    oauth_init_inputs.set_ForwardingURL('http://127.0.0.1:4567/finalize')
    
    oauth_init_results = oauth_init_choreo.execute(oauth_init_inputs)
    
    # Populate the global callback ID.
    $callback_id = oauth_init_results.get_CallbackID()
    # Proceed to the authorization URL to grant this app access to your
    # Facebook info.
    redirect oauth_init_results.get_AuthorizationURL()
end

get '/finalize' do 
    # Complete the OAuth process.
    oauth_final_choreo = Facebook::OAuth::FinalizeOAuth.new($temboo_session)
    
    oauth_final_inputs = oauth_final_choreo.new_input_set()
    oauth_final_inputs.set_AppID($app_id)
    oauth_final_inputs.set_AppSecret($app_secret)
    oauth_final_inputs.set_CallbackID($callback_id)

    oauth_final_results = oauth_final_choreo.execute(oauth_final_inputs)

    # Using the token obtained in the OAuth process, display user info.
    user_choreo = Facebook::Reading::User.new($temboo_session)
    
    user_inputs = user_choreo.new_input_set()
    user_inputs.set_AccessToken(oauth_final_results.get_AccessToken())
    user_results = user_choreo.execute(user_inputs)
    user_results.get_Response()
end