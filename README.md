# podcast

The Request for Explanation podcast that explains Rust RFCs

This is an unofficial community-driven project.

## Have an RFC you'd like explained?

Please file an issue on this repo with a link to the RFC PR! 

We're open to discussing RFCs in many different states, whether they've just been opened, they're about to enter or in their 
Final Comment Period, or if they've been merged or implemented. We'll probably lean more towards RFCs that are getting team 
approval and about to enter FCP, so that people can learn about the discussion and revisions that have happened and then go 
comment once they understand the issues.

## Want to discuss an RFC?

We'd love to have guests on! Whether you're an RFC author, someone interested in a particular RFC, or someone who has questions
about what an RFC means, you'd make a great guest! Please indicate your interest on an existing issue or file a new issue for
the RFC you're interested in and let us know you'd like to be a guest.

## License

<a rel="license" href="http://creativecommons.org/licenses/by/4.0/">
  <img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/88x31.png" />
</a>

The text and audio for this podcast (anything in this repo) is licensed under a [Creative Commons Attribution 4.0 International License](http://creativecommons.org/licenses/by/4.0/).

## Building workflow

* make `$DIR` for episode
* add `$DIR/episode.mp3` (and friends)
* copy `src/template.md` to `$DIR/index.md`

* replace all `$VARIABLES` in `index.md` with content
* `./build.sh $DIR` (must have `rustdoc` in your path)
* tweak `index.md` and repeat previous step until happy
* add entry to rss.xml and index.html

* `git add .`
* `git commit -m "episode xxx"`
* `git push`

You can tweak the CSS without regenerating anything, but any edits to `src/*.html` (which rustdoc injects in certain places) 
will require a rebuild of every episode. Changing the template will require a manual edit of every episode, followed by a 
rebuild of every episode.
