Rails.application.routes.draw do
  get '/fake/new' => 'fake#new'
  get '/fakes' => 'fake#index'
  get '/fake/(:id)' => 'fake#show'
  get '/fake/edit' => 'fake#edit'
  get '/fake/nested_array' => 'fake#nested_array'
  get '/fake/nested_array_optional_element' => 'fake#nested_array_optional_element'
  get '/fake/nested_array_required_element' => 'fake#nested_array_required_element'
  post '/fake/ary' => 'fake#ary'
  post '/fake/array_optional_element' => 'fake#array_optional_element'
  post '/fake/array_required_element' => 'fake#array_required_element'
end
