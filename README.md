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

The API reference documentation has moved to the [Ruhue Wiki][], and is mirrored
by the [wiki branch in the Ruhue repository](https://github.com/Burgestrand/ruhue/tree/wiki). Please
make your contributions by forking, branching off the wiki branch, and sending pull requests.

If you want commit access to the Ruhue repository (and thus, the wiki), send me an e-mail!

**Note:** I plan to move the API documentation refernce to a gh-pages branch, and use [GitHub pages][http://pages.github.com/]
to host it instead. The reason for this sudden change is that the Gollum wiki used by GitHub does not allow slashes in page names.
My hope is GitHub pages will be a better fit for describing the documentation, but if that does not work out I’ll have to
find another way.

[Ruhue Wiki]: https://github.com/Burgestrand/ruhue/wiki
