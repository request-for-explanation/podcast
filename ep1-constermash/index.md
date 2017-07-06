% Request For Explanation #1 - Constermash

<div class="date">June 29, 2017</div>

This week we look at [RFC 2000](https://github.com/withoutboats/rfcs/blob/const-generics/text/0000-const-generics.md)
"Const Generics"

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

* [Current array documentation](https://doc.rust-lang.org/stable/std/primitive.array.html)
* [smallvec crate](https://crates.io/crates/smallvec)
* [typenum crate](https://crates.io/crates/typenum)

## Panelists

* Carol Nichols
* Manish Goregaokar
* without boats

## Transcript

Transcription courtesy of wirelyre! Thank you! <3

Carol Nichols: Hi, everyone. Welcome to Episode 1 of the Request for Explanation
podcast. Today we have me, Carol Nichols—

Manish Goregaokar: me, Manish—

@withoutboats: and I'm @withoutboats.

CN: And today we're discussing RFC 2000 on "const generics". So, boats, what is
the motivation behind this RFC and what does it let us do?

wb: Rust today has arrays, which have a length as part of their types, so you'll
have an array of, for instance, length 1, length 2, and so on. Right now you
can't abstract over arrays of different lengths. One way that this affects
libraries and usages is that, in the standard library, we've decided to
implement traits for arrays up to length 32, but if you have an array that's
longer than 32, you're just out of luck. If you want to include arrays in a
type, you have to specify that length. You can't have a type that has an
array in it that's some [arbitrary] length.

What this will let you do is write abstractions over arrays of any length,
by adding a new parameter that's a `usize`, because array length is a
`usize`. So you'll say `impl Clone for [T; N]`, where `N` is any number.

CN: That sounds really cool. So after this is implemented, I'll be able to
`clone` arrays of size 33?

wb: Yes, after this is implemented, we'll have all those traits implemented for
any array of any size.

CN: And does this mean the docs of array are going to be a lot shorter as well?

wb: Yeah, hopefully. They'll all have just one impl instead of 32 impls for
every trait. And there are some traits that we haven't been able to
implement, because it's too hard to implement them for each of these.

Like iterators, for example. Arrays don't have `IntoIterator` and now they
will be able to.

MG: So what does this let me do? What does this let us do aside from just
abstracting over writing `Clone` impls for arrays and stuff like that?

wb: It's sort of a more general feature than just solving this for arrays. We
try not to have a special case like this. What it does is, it lets you make
types and impls and traits and things that are parameterized over constant
values.

Right now you can parameterize them over types, so like a `Vec`, an
`Option`, and things like that are all types that have a type parameter. Now
you can create things that have a "const" parameter, which is any value that
is known at compile time. It could be an integer, a string. It could be all
kinds of different types as long as it can be known at compile time. All
kinds of different values, I mean.

MG: One major use case for this is linear algebra libraries, where you have
matrices, and you don't want to just say, "Oh, I'm going to let you use a
matrix of [1x1] or 2x2 or 4x4 and nothing else," you want the user to be
able to say, "Yes, I want a matrix that's gigantic" and you don't want to
have to specify all the types they can use beforehand.

wb: Yeah, exactly. Things like that, like multiple-dimensional arrays, different
sort of cryptographic primitives — people have a lot of use cases for where
they want to be able to do this. High-performance numerics computing is a
very obvious use case.

MG: One interesting use case that Servo uses a lot is this crate called
"smallvec", which is basically a `Vec`, but it will store the elements on
the stack, up to a certain length. We wish to parameterize over the length,
and we do that with some hacky stuff right now, but this would be a much
nicer API and make it much easier to use.

CN: Cool. In the RFC, boats, you mention that this is kind of an advanced
feature. How advanced do I need to be? What kinds of things do I need to
know before using these features and how will I know that I need this?

wb: I think that there are two different stories here. There's a difference
between using an API that uses this feature, and writing an API that uses
this feature. And so it's a lot like type parameters. Users are going to
start using `Vec`s very quickly, and those have type parameters in them.

And I think probably, as APIs develop with this feature, there will be some
that users will use a lot. Like arrays, for example. Right now people don't
really use regular arrays because of the issue with them, but now it will be
much more common.

But in terms of defining your own types that are parameterized over consts,
probably will be comparable to writing your own generic types. Because it's
just a kind of generic type. So it's not something that we think users are
going to run into immediately. It's more of a library author use case than
an end user use case.

MG: [How] will I know when I actually need to use this?

wb: That's a good question. One situation that we have right now is, there's a
library called "typenum" which essentially creates a type for numbers up to
some huge number, and you use those types as generics to have types that are
generic over numbers. But they're not real numbers, they're types that stand
in for numbers.

If you ever thought that maybe that would be a good idea to use — your
compile times right now will be terrible if you try to use that — this would
be basically a replacement for that. When you would be creating types to
represent something that [doesn't] really make sense as types, it might be a
better idea to use this feature.

Numbers are where it's gotten a lot of attention, but even things like, if
you just need a marker, and it just needs to have a name, it might make more
sense to be parametric over a string, and people can write whatever string
they want there, instead of having to create a dummy type that doesn't have
any data in it.

CN: And that would only work with `&'static str`s, yes?

wb: Yes, string literals.

CN: Cool. So this RFC is close to being merged. Can you talk about some of the
problems and challenges that have been worked out in this RFC?

wb: Yeah. The first big question we had to resolve was syntax. Obviously there
was a lot of syntactic proposals and bikeshedding around the syntax. We've
come up with one that we think is pretty consistent with the rest of the
language's syntax. Essentially, if you want to create a new const parameter
that you're generic over, you just add an extra parameter prefaced with the
keyword `const`: `<const N: …>` and then the type of `N` which might be
`usize`, `i32`, `&'static str`, whatever.

But there were harder semantic questions to resolve about, how far do we go
on what's called "unification"? So when we're trying to type-check your code
and we need to use type inference to figure out what the types of all the
values in your function are, we may need to figure out if two different
types that we have are actually the same type. That process is called
"unification". When we're dealing with constants, that means we could be
dealing with arbitrary expressions. How do we know, for example, does `N+1`
unify with `N+2`? Probably not, but [the] harder question is, does `N*2`
unify with `2*N`? If we don't know what `N` is, is it possible that two
different equations can be used to determine `N` by sort of backwards SAT
solving them?

That's where it gets very advanced and very tricky, so right now we've
decided to do something very conservative and minimal, which is, unless it's
literally the same expression you wrote once, we don't attempt to unify
them. For every expression, we treat them as unknown values, and we don't do
any sort of computation to solve them.

CN: And in order to let things like `N*2` unify with `2*N`, the compiler would
need to know how to do math, right?

wb: Yeah.

CN: And that's not something it knows how to do currently, and sounds like a big
project.

MG: Well…

wb: The thing we need to know is that multiplication [is commutative]. And
especially, since we have operator overloading, what if it's not `2`, what
if it's a user-defined type? There's a lot of design questions that we have
to decide about.

MG: The compiler can already do some math, like you can say `const N = 1+2+5;`,
and it will do that math and put that in `N` at compile time. And you can do
pretty complicated stuff in there.

CN: So it's not so much math, it's more, like, math rules.

MG: Yes. It's math that needs to be able to figure out the identity of things.
Here it's just computing things, but you may not ultimately know what `X`
is. `X` could be a free parameter. Then you have to do algebra and find the
identity of stuff, and nobody likes algebra.

wb: Exactly. You actually can have types right now like an array of length
`2+2+2+2`. The compiler will accept that and figure out that it's eight. The
problem comes when it's got a variable that the compiler doesn't know what
the number is, and trying to take two of those expressions that can't be
evaluated fully and figure out that they're actually the same expression.

MG: For example, if you have the constant `X` and you don't know what it is, but
you might be able to infer its value, would you take `X+2` and `X*2` and
look at the fact that they're the same, and determine that `X` is two? Or is
this too much math?

wb: And even, far before that kind of thing, just figuring out that `X+2` and
`2+X` are the same also raises a lot of questions. Right now we're not doing
any of that. We're sticking to just treating them as unknown. We don't know
what it evaluates to, and so we don't that it will unify with anything else.
Even if it's literally, you have `N+1` here and `N+1` here, we won't be able
to tell that they're the same type for now.

MG: Basically, you have to use the same [const] name everywhere. You should
[bind a const name] and use that.

wb: Yes, though you actually won't be able to do that at first, because you
can't alias with a parameter in it. And that raises some other questions.
It's very similar to when you want to have a type alias inside of a function
that has a type parameter, but the type parameter can't be just used in the
alias, so you have to add an extra parameter to the alias. There's questions
about whether we should allow that or not. That's a whole other decision.

CN: So this is all future work that could be enabled by this RFC, but this RFC
does not include at this time?

wb: Right. This RFC is the starting point to a very rich and complex space of
possible extensions to the language that a lot of people are very excited
about. We're sort of dipping our toes into that right now.

MG: Another extension there would be `where` bounds, like being able to say
"where this integer is smaller than this other integer" or something like
that. That's also complicated.

wb: We might get there someday, and especially people who write cryptography
really want that feature where they can prove that their code, the value
stays within a certain range. I don't actually know anything about
cryptography but it's important for safety and security somehow. And that
would require those kinds of `where` clauses.

We'd like to support those use cases, but I'm a little bit concerned about
the sort of API proliferation problems of suddenly having libraries with
these huge `where` clauses proving very complicated things and expecting
people to understand what their API is doing. There are just a lot of design
questions around that.

CN: Most of the comments on the RFC seem to be about the syntax or this
unification problem. Are there any other topics in the discussions?

wb: There's sort of one open question right now, which has to do with defaults
and ordering the parameters, the big questions are unification stuff and how
far we're going to go at first and how conservative we're going to be just
now.

MG: There was also the question about locals. One thing that the RFC does not
allow is basically, within a function, declaring a constant and then using
that constant that's local to the function, in the types for static or
constant types local to that function. You can do this globally, but not
locally, for various reasons.

wb: It's essentially the same problem as, if you have a function inside of a
function, you can't use type parameters from the outer function. Similarly,
if you have a const inside a function, you can't use the const parameters
from the outer function. And it's possible we could allow this, but that
would be a separate RFC from this one.

CN: Okay. That all sounds great, and I'm looking forward to this getting merged
and implemented. Again, it's close to being merged, so if anyone would like
to give comments on this, this is a great time to do so. Are there any kinds
of comments that you are particularly looking for right now?

wb: I'm especially interested in hearing people who have use cases where they
think they need this, and understanding what they actually want to use it
for, because, as we've touched on, there's a lot of different ways we can go
in extending this further, and it's hard to know what to prioritize given
all that space. So having different people come in with different use cases
and being able to see what is most commonly requested, and what should we
prioritize the most.

CN: And if this RFC is going to address their use case or not.

wb: Yeah, that's also very important.

MG: How far off do you feel that the implementation would be? Which Rust nightly
would I expect to see this in?

CN: When's this gettin' done, boats?

wb: Yeah, uh. So the RFC is pretty close to entering the pre-FCP [final comment
period] where we all check boxes to say that we approve it. I need to make
some edits and then I'd probably like to propose to merge it. And then eddyb
is going to be working on it, and he says that he thinks he could have the
implementation done by sometime in fall. So we could have it in nightly by
end of the year, and then it's a question of when we stabilize it, when we
think it's got no bugs, and things like that.

MG: So this does not depend on chalk and stuff happening?

wb: No, this is totally orthogonal to chalk.

CN: That sounds like a topic for a future episode.

wb: Yes.

CN: So if you don't know what chalk is, we'll get to that.

wb: Chalk is another big project.

CN: Okay. Thank you so much for being on the show. And people listening to this,
please suggest RFCs on our GitHub repo at
[https://github.com/request-for-explanation/podcast]. Thank you for tuning
in. Bye.

[16:09]