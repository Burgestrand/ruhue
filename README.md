# Ruhue (NOT ACTIVELY MAINTAINED)

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
hosted on <http://burgestrand.github.com/hue-api/> using GitHub Pages. Contributions
are very welcome, and if you’d like commit access to the hue-api repository, just ask!

[hue-api]: https://github.com/Burgestrand/hue-api

## Gem License

Copyright (c) 2012 Kim Burgestrand

MIT License

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
