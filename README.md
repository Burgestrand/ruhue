# Ruhue

So far, mere documentations of my findings when sniffing the Hue.

There is a mailing list, dedicated to discussions and questions about hacking the
Philips Hue and related protocols.

- Mailing list web interface: <https://groups.google.com/d/forum/hue-hackers>
- Mailing list e-mail address: <hue-hackers@googlegroups.com>

Other link resources:

- [Hack the Hue](http://rsmck.co.uk/hue)
- [A Day with Philips Hue](http://www.nerdblog.com/2012/10/a-day-with-philips-hue.html?showComment=1352172383498)

## Console

There is a console script in this repository, written by @Burgestrand as the
documentation effort travels further. It is written in Ruby, and only supports
Ruby 1.9.x and newer. You may start the console with the following:

1. Install bundler: `gem install bundler`
2. Install console script dependencies: `bundle install`
3. Run the console script: `ruby console.rb`

You’ll be dropped into a pry prompt (similar to IRB), with access to the following
local variables:

- hue — a Hue instance, documented in `lib/hue.rb`
- client — a Hue::Client, documented in `lib/hue/client.rb`

Once the Hue API exploration adventure starts slowing down, the scripts will be
turned into a ruby gem and tested with rspec.

## API

The API reference documentation has moved to the [hue-api][] repository. It is
hosted on <https://burgestrand.github.com/hue-api/> using GitHub Pages. Contributions
are very welcome, and if you’d like commit access to the hue-api repository, just ask!

[hue-api]: https://github.com/Burgestrand/hue-api
