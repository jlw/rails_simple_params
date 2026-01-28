# rails_simple_params

_Parameter Validation & Type Coercion for Rails_

## Introduction

This library is handy if you want to validate a few numbers of parameters
directly inside your controller.

For example: you are building a search action and want to validate that the
`sort` parameter is set and only set to something like `desc` or `asc`.

## Important

This library should not be used to validate a large number of parameters or
parameters sent via a form or namespaced (like `params[:user][:first_name]`).
There is already a great framework included in Rails (ActiveModel::Model) which
can be used to create virtual classes with all the validations you already know
and love from Rails. Remember to always try to stay in the “thin controller” rule.

[See an example on how to build a contact form using ActiveModel::Model.][active-model-example]

Sometimes it’s not practical to create an external class just to validate and
convert a few parameters. This gem allows you to easily validate and convert
parameters directly in your controller actions using a simple method call.

## Credits

This is a fork of the gem [rails_param][gem-rails-param], which was itself a
port of the gem [sinatra-param][gem-sinatra-param] for the Rails framework.

## Installation

As usual, in your Gemfile...

``` ruby
  gem 'rails_simple_params'
```

### Migrating from `rails_param`

Change any code you have rescuing `RailsParam::InvalidParameterError` to instead
rescue `RailsSimpleParam::InvalidParameter` so you will continue to provide any
customized HTTP `4xx` responses appropriate for your app.

If you want to handle different types of validations separately — especially if
you want to handle your own I18n translations for the default English error
messages provided by this gem — you can rescue from any/all of the sub-classed
exception classes:

- `RailsSimpleParam::EmptyParameter`
- `RailsSimpleParam::InvalidFormat`
- `RailsSimpleParam::InvalidIdentity`
- `RailsSimpleParam::InvalidOption`
- `RailsSimpleParam::InvalidType`
- `RailsSimpleParam::MissingParameter`
- `RailsSimpleParam::OutOfRange`
- `RailsSimpleParam::TooLarge`
- `RailsSimpleParam::TooLong`
- `RailsSimpleParam::TooShort`
- `RailsSimpleParam::TooSmall`

## Using this Gem

``` ruby
  # GET /search?q=example
  # GET /search?q=example&categories=news
  # GET /search?q=example&sort=created_at&order=ASC
  def search
    param! :q,          String, required: true
    param! :categories, Array
    param! :sort,       String, default: 'title'
    param! :order,      String, in: %w(asc desc), transform: :downcase, default: 'asc'
    param! :price,      String, format: /[<\=>]\s*\$\d+/
    param! :results,    Integer, in: (10..100)

    # Access the parameters using the params object (e.g. `params[:q]`) as you usually do...
  end
end
```

### Parameter Types

By declaring parameter types, incoming parameters will automatically be
transformed into an object of that type. For instance, if a param is `:boolean`,
values of `'1'`, `'true'`, `'t'`, `'yes'`, and `'y'` will be automatically
transformed into `true`. `BigDecimal` defaults to a precision of 14, and this
can be changed by passing in the optional `precision:` argument. Any `$` and `,`
are automatically stripped when converting to `BigDecimal`.

- `String`
- `Integer`
- `Float`
- `:boolean/TrueClass/FalseClass` ('1/0', 'true/false', 't/f', 'yes/no', 'y/n')
- `Array` (e.g. '1,2,3,4,5')
- `Hash` (e.g. 'key1:value1,key2:value2')
- `Date`, `Time`, & `DateTime`
- `BigDecimal` (e.g. '$100,000,000,000')

### Validations

Encapsulate business logic in a consistent way with validations. If a parameter
does not satisfy a particular condition, an exception
(RailsSimpleParams::InvalidParameter or one of its subclasses) is raised. You
may use the [rescue_from][method-rescue-from] method in your controller to catch
this kind of exception.

- `blank`
- `format`
- `is`
- `in` (for arrays / ranges / sets)
- `min` / `max`
- `min_length` / `max_length`
- `required`

Customize exception message with option `:message`

```ruby
param! :q, String, required: true, message: 'Query not specified'
```

### Defaults and Transformations

Passing a `default` option will provide a default value for a parameter if none
is passed. A `default` can be defined as either a default value or as a `Proc`
(and `in` options can also be a `Proc`):

```ruby
param! :attribution, String, default: '©'
param! :year, Integer, in: lambda { (Time.now.year-5..Time.now.year+5) }, default: lambda { Time.now.year }
```

Use the `transform` option to take even more of the business logic of parameter
I/O out of your code. Anything that responds to `to_proc` (including `Proc` and
symbols) will do.

```ruby
param! :order, String, in: ['ASC', 'DESC'], transform: :upcase, default: 'ASC'
param! :offset, Integer, min: 0, transform: lambda {|n| n - (n % 10)}
```

### Nested Attributes

rails_simple_params allows you to apply any of the above mentioned validations
to attributes nested in hashes:

```ruby
param! :book, Hash do |b|
  b.param! :title, String, blank: false
  b.param! :price, BigDecimal, precision: 4, required: true
  b.param! :author, Hash, required: true do |a|
    a.param! :first_name, String
    a.param! :last_name, String, blank: false
  end
end
```

### Arrays

Validate every element of your array, including nested hashes and arrays:

```ruby
# primitive datatype syntax
param! :integer_array, Array do |array,index|
  array.param! index, Integer, required: true
end

# complex array
param! :books_array, Array, required: true  do |b|
  b.param! :title, String, blank: false
  b.param! :author, Hash, required: true do |a|
    a.param! :first_name, String
    a.param! :last_name, String, required: true
  end
  b.param! :subjects, Array do |s,i|
    s.param! i, String, blank: false
  end
end
```

## Many thanks to

- [Nicolas Blanco](http://twitter.com/nblanco_fr)
- [Mattt Thompson](https://twitter.com/mattt)
- [Vincent Ollivier](https://twitter.com/vinc686)

## License

rails_simple_params is available under the MIT license. See the LICENSE file for more info.

[active-model-example]: http://blog.remarkablelabs.com/2012/12/activemodel-model-rails-4-countdown-to-2013
[gem-rails-param]: https://github.com/nicolasblanco/rails_param
[gem-sinatra-param]: https://github.com/mattt/sinatra-param
[method-rescue-from]: http://api.rubyonrails.org/classes/ActiveSupport/Rescuable/ClassMethods.html#method-i-rescue_from
