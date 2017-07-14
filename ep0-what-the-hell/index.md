% Request For Explanation #0 - What The Hell

<div class="date">June 19, 2017</div>

This week we look at [RFC 2005](https://github.com/rust-lang/rfcs/pull/2005)
"Match Ergonomics Using Default Binding Modes"

<audio controls="controls">
    <source src="episode.mp3" type="audio/mp3">
    <source src="episode.ogg" type="audio/ogg">
    <source src="episode.m4a" type="audio/x-m4a">
</audio>


## Downloads

* [MP3](episode.mp3)
* [OGG](episode.ogg)
* [MPEG-4](episode.m4a)


## Notes

* [RFC 1944](https://github.com/rust-lang/rfcs/pull/1944), the predecessor of #2005

## Panelists

* Carol Nichols
* Alexis Beingessner
* Manish Goregaokar

## Transcript

Transcription courtesy of wirelyre! Thank you! <3

Carol Nichols: Hi everyone. Welcome to the inaugural episode of the Request for
Explanations podcast, where we discuss Rust's RFCs. On the show today is me,
Carol Nichols,---

Alexis Beingessner: me, Alexis Beingessner,---

Manish Goregaokar: and me, Manish Goregaokar.

CN: Today we're going to be discussing the match RFC.

This podcast is a means to help everyone keep up with RFCs that are going
through. This idea actually came from the IRC user misdreavous last December,
and recently Alexis brought up a summary of this match RFC that was a really
great summary, which reminded me of this idea. So we're finally starting to do
it.

So, Alexis. Talk to us about RFC 2005.

AB: This RFC is part of the Rust core team's new big ergonomics initiative for
the year. There's a bunch of tiny little paper cuts in the language which, once
you learn the language, it's like, whatever, this is some work that I need to
do, but: a) everyone hates doing it; and b) it trips up newbies a lot. They're
like, "What the hell is this language? Why do I need to do this? What's
happening? Does this mean anything important?" And this [RFC] is trying to
focus on the way match patterns work.

If you've used Rust for a while, you've probably had to match on certain enums
in a nontrivial way. For instance, you match on an `Option` and you want to
take a reference to the value inside of the `Option`, rather than just copying
or moving the value. When you want to do that, it ends up being a bit messy.

Today, if you, say, have a `&Option` and you try and match on it the same way
you would match on a `Option`, you will get a compilation error. It will say
"error[E0308]: mismatched types". And you'll be like, "What the heck are you
talking about?"

What it's saying is, basically, "Hey, you said you'd be passing a value
`Option`, but you passed a reference to a value." There's two ways you can fix
this. You can either dereference your `Option` at the start of the match, or
you can add a reference inside the pattern and tell the compiler, "Hey, there's
supposed to be a reference here. I know that. I'm going to reach through the
reference and grab the value instead."

And then, once you want to actually take a reference to the field, you again
have to say, "Hey, actually take a reference to this thing." The way you do
this is with something that is literally nowhere else in the language: the
`ref` keyword. It just says, "Hey, take a reference to this thing."

The reason you need that is because patterns are weird and backwards. We put
the ampersand to say "Hey, undo this reference." There is technically a symbol
for "Do this reference." So you need a symbol for "Undo this reference to
create a reference." And in theory, that could have been the star, because
that's how you dereference a pointer. But everyone decided that was confusing.

So you end up having this thing where you have to manually dereference your
thing and manually rereference your thing. And this is a bit annoying, because
there's lots of places in the language where we don't bother doing that. Why do
we need to do this in patterns?

The really big example is closures. If you have a closure, you just say "Hey, I
want to use this value," and it's just like "Cool, I'll figure out how to do
that for you." The other really major place is the dot operator. The dot
operator will just magically be like "Oh, I see you have a reference there.
Obviously you don't want to call a method on this reference. I'm going to dig
into the actual value and do the stuff you wanted."

This RFC says, "There's this really common case where you have a reference and
you want to take a reference to the contents. We're going to add a fallback for
this case." Today, it would be considered a mistake, and with this RFC it
triggers a fallback.

And it's a similar fallback to the integer fallback. You might be familiar with
the integer fallback in Rust: if you say `let x=0;`, most of the time, that
will be inferred. It will figure out, "Oh, you're using this integer as a
`usize`. I'm going to assume it's a `usize`." Then everything works. But in
some code --- notably, examples and tests --- it will be "Oh, I don't know what
to do. Nothing incurs this integer to be a type. I'm going to fall back to
`i32`. If I don't know what to do and I'd be forced to give a compilation
error, I'm just going to say it's `i32`."

This match RFC is doing a similar thing. It's saying, "Oh, I don't know what to
do because you said you have a `Option`, but you actually gave me a `&Option`.
I'm going to fall back to assuming you want to dereference that and take a
reference to the contents." This will always work, and it wills only change
code that didn't compile before. It's strictly backwards compatible. Everyone's
code continues to work the same, except, if you did this code that didn't
compile before, it will now compile. Everyone can remove a bunch of `ref`s and
`&`s from their code.

Similarly, for mutable references, it will do the same thing. If you have a
mutable reference and `ref mut`, you can just elide both of those.

CN: Does this mean that, once this is implemented, we'll never need to type the
`ref` keyword ever again?

AB: Unfortunately not. Well, that's interesting... I'd need to think about all
the implications.

An example someone brought up during the discussion is, "I like using `ref` and
`ref mut` in the same patterns to explicitly state, 'These should be mutated;
these shouldn't be mutated.'" If you want to enforce that, then you have to use
`ref` and `ref mut`.

And as far as I can tell, this system is very hostile towards mix and matching.
You can't be like, "Oh, I want to infer these fields but actually do the `ref`
on these. If it's easier trying to mix and match the old and new mode, it just
gives up and gets you there.

MG: I think in the RFC they've made it sort of sidestep inference, basically
because they don't want inference to be influenced by this `ref` keyword. So
there are places where you may need explicit `ref` because guessing the `ref`
keyword leads to inference issues.

There's an example in the RFC where there's a `Vec` of unknown type and they
don't want to infer the type based on the body, so they're going to use the
`ref` keyword.

AB: That's actually a really good point. The logic the compiler needs to
implement is basically, "Look at the type of the input, and then look at the
shape of the pattern." From those two facts, it can figure out exactly which
rule we're applying. It never needs to look at the body of the match, modulo
that the body of the match can actually affect the inference of the type of the
input to the match. But that shouldn't affect whether it's a reference or not.
I don't think.

MG: Well, the example is matching on the result of an index. And when you index
something with the indexing operator, you get this sort of state that's between
a reference and not a reference.

CN: What now?

MG: When you use the indexing operator, it actually does something that's like
moving out of an index. But you don't want to move. I guess it gives you a
temporary, and you can match on the temporary and use `ref` to deal with it.
But if you want to use it, you're forced to put the ampersand operator right
before it. But Rust in certain situations allows you to do things as if you
were moving out, provided that you don't actually need to move out.

TL;DR: You can do `match vector[some number]`. Then if you're not allowed to
move out of the vector.

AB: Right. The reason this works is the same reason that `match *(a reference)`
works. The index operator behaves as if there was an implicit dereference
before it.

CN: I think I get it. Maybe.

AB: I think the exact mechanics of this, you have to start getting into "What's
an rvalue? What's an lvalue?" And I don't want any part of this.

CN: Oh, no. No.

AB: I think there should be a hard rule that we never explain what an lvalue or
an rvalue is on this podcast.

[laughter]

CN: To switch the subject, this RFC was actually the successor to another RFC.
Do either of you want to summarize the previous RFC and how that was different
from this one?

AB: I will warn that I have not actually properly read this RFC. I have only
read the discussion around it. My understanding of it is basically, it was
trying to make matches behave sort of like closures do.

Today, if you have a closure, as I mentioned, and you use some closed-over
variable, it will just kind of figure out how to capture the variable. If you
only read it, it will capture it by reference. If you mutate it, it will
capture it by mutable reference. And if you consume it by value, it will move
it into the closure. The last one is pretty obscure to trigger, but there are
ways to do it.

Matches would be the same way. It would look inside a branch, and it would
look, "Oh, you only read this value that you match on? I'm gonna bind on it by
reference. You mutate this value? I'm gonna bind on it by mutable reference. Or
you move it into the branch? I'm gonna move it in." And I think, similar to
closures, there's some fail cases where the inference will go, "Oh, you only
read it or write it? You only need a reference." But you actually need to move
it in for whatever reason. So I think you'd be allowed to use the `move`
keyword in matches now, like "Move this pattern in," explicitly.

The problem with this is basically --- well, a) a lot of people were terrified
because it's magic and the Rust community has taken a hard stance of "Magic's
scary." I know I probably freaked out the first time someone suggested doing
this. I have a feeling a lot of other people on the Rust teams also freaked out
when Aaron and Niko started being, "Hey, what about this?"

But, more seriously, the reason it was considered trouble was, it changed the
semantics of existing code. Rust is a bit underspecified, so you could maybe
rules lawyer, "Oh, we never actually guaranteed this," but in practice, Rust is
pretty strict, and it did guarantee that, if you match on something by value,
the stuff you bound by value would be moved into the body of the branch. And
with this new system, it could see, "Oh, you actually only read the value. I'm
going to only bind it by reference." This would change when destructors run.
And that could be pretty serious. For instance, it could mean that the lock on
a lock could be held longer than it should be. And maybe you'll get deadlocks,
or maybe your program will just run slow because there's a lot more lock
contention going on.

I'm not sure if anyone had any code where it was like, "I'm actually relying on
this," but it was one of those, like, "Let's not break the people's stuff." And
this was one of the motivations for all of this discussion that was going on
about whether Rust 2.0 should happen, and whether we would have, similar to
C++, "I'm using Rust 2.0-standard semantics. Please change the semantics of my
code to use the new matches that are much nicer to use, but a little tricky."

CN: Well, I'm not sure that we'll ever go to Rust 2.0 in the
fully-breaking-and- abandoning-backwards-versions, but that's the topic for a
future episode.

So it sounds like the new RFC landed on something that's pretty nice. It keeps
backwards compatibility but makes the ergonomics a lot better.

AB: Yeah. There is some small concern for, if you're a novice, or even just an
intermediate person who's really not feeling it today, there's a lot of times
where you're like, "Ah, why isn't this code compiling?" and you'll just try and
add or remove references or add `clone`s.

CN: There's a comment of Aaron's on RFC 2005 that says, "This is basically how
my mind always wants pattern matching to work, before I remind myself to go
sprinkle in `ref`s." I don't think I'd call Aaron an "intermediate." I think
he's pretty advanced. Pretty advanced people do this too.

AB: Absolutely. Basically, the concern is, when you're in this mode of "Why
isn't this working?" --- again, you could be a beginner or an advanced person
who's tired or having none of this --- you could end up getting the wrong thing
because now more things compile. Before, it was like, you really have to figure
out what you want and nail it down. Now there's two ways to get the same thing.

So there's some concern that maybe that will lead to more erroneous code. But
when I looked at it, it's pretty tough to produce this code. It's sort of like
you have to make a double sign error, if you've ever seen that in code, where
it's like, "Oh, I actually messed this code up twice, and it got the right
thing because they cancelled each other out." Any way you can screw up the new
matches, you have to make this kind of double mistake.

MG: My concern is somewhat related. It's what I call like, "The union of a
simple system and a complex system is not a simple system." When you have
something complex and you try papering over the complexity with magic, what
ultimately happens, in most cases, is that the complexity is still there. And
you eventually have to learn this. You have folks wondering, "Why did this
magic not work?" That's an additional layer of complexity that people have to
think about while learning the language.

Which you eventually get over. One case of this is with lifetimes, where you
start off relying on elision, and when it doesn't work, you basically blame the
language and just walk away and never use Rust again. And when you're
intermediate, you're able to switch between the two, but you don't know where
each one will work. And when you're advanced, you again know that you should
just be relying on elision all over the place, but you also know exactly when
it's not going to help you and you write the code before the compiler yells at
you.

It's the same thing here. It takes a long time to get to that stage where you
understand that this is a piece of magic. It's not the same feature; these are
two separate things and there's some magic above it, and the magic sometimes
applies, but not always. And when you're learning a language without proper
guidance, you're going to end up, you know, not realizing that.

CN: Okay. We're trying to keep this around 20 minutes to be short and
digestible, so I think that's all the time we have for today. If you have an
RFC that you'd like us to discuss, please go to
[https://github.com/request-for-explanation/podcast] and file us an issue with
the RFC you want us to talk about. I'd like to thank 'cramertj' for authoring
the RFC we discussed today. Any parting words from anyone?

AB: This change was good. Happy it's landed. We'll probably use it as soon as
it's on stable.

CN: Yeah, that's a good point. This RFC has been merged but not yet
implemented. I believe the implementation issue is looking for someone to
implement it, and there are mentors offering to help you. So go check that out
if you're interested in being the one to implement this.

All right, tune in next time to see if we stumble as much as we did this time.
Thanks for listening.

[20:29]
