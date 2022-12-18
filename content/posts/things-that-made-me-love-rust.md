---
title: Things that made me love Rust
date: 2022-05-06
---

I have recently started working on the final project for the University, and I decided to do it in [Rust](https://www.rust-lang.org/), mainly to learn
more about the language.
You can try to learn a language by just reading, but the actual learning comes from actually writing code and facing the
creation of a working program.

I am currently a [Go](https://go.dev/) developer at [Sysdig](https://sysdig.com/), and I have to admit that I tried to write Rust code like I wrote Go. This is a
mistake; both languages are very different from one another. Some things I wanted to do in Go, I couldn't because the
language is designed to be too simplistic. I understand the tradeoffs of Go, but having to write some algorithms
yourself all the time, is just too tedious.

So here are some things that made me love the language for how it is designed.

# Traits

Traits in Rust can be understood as [Interfaces](https://en.wikipedia.org/wiki/Interface_(object-oriented_programming))
in other languages like Go or Java. They are mostly the same, but there are some differences that, in my opinion, 
make Traits much more powerful. In particular, you can
use [Trait bounds](https://doc.rust-lang.org/book/ch10-02-traits.html#trait-bound-syntax) to implement methods or other 
traits conditionally.

For example, let's say you have a tuple:

```rust
struct Tuple<T> {
    first: T,
    second: T,
}

impl<T: PartialOrd> Tuple<T> {
    fn smaller(&self) -> &T {
        if self.first < self.second {
            self.first
        } else {
            self.second
        }
    }
}
```

The `Tuple<T>::smaller` method will only be available if the generic type `T` provided in the Tuple implements
the [`PartialOrd`](https://doc.rust-lang.org/std/cmp/trait.PartialOrd.html) trait, which is [implemented](https://doc.rust-lang.org/std/cmp/trait.PartialOrd.html#implementors), for example,
for most of the data types in the standard library, but maybe not for custom structs.

----

Another example would be the [`From`](https://doc.rust-lang.org/std/convert/trait.From.html) trait:

```rust
pub trait From<T> {
    fn from(T) -> Self;
}
```

This trait allows any type that implements it to transform from type `T` to this type.
For example, `impl From<bool> for i64` allows to transform from `bool` to `i64`, so you can do:

```rust
let x: bool = true;
let y: i64 = i64::from(x);
```

Then I found the opposite trait: [`Into`](https://doc.rust-lang.org/std/convert/trait.Into.html).
This allows explicit transformations like:

```rust
let x: bool = true;
let y: i64 = x.into();
```

I thought: _"Wait, isn't this repeating the same thing? If you want to transform from `bool` to `i64`, you
need
to be consistent and implement both."_.

Fool of me! You don't need to implement the `Into` trait yourself! It is implemented for **ANY** type that
implements `From` using
conditional trait bounds:

```rust
impl<T, U> Into<U> for T
where
    U: From<T>
{
    fn into(self) -> U {
        U::from(self)
    }
}
```

# Derive clauses

This is one of my favourite features of Rust. It allows you to create default implementation of traits for your types,
by just writing `#[derive(...)]` in the type definition.

Let's say I want to have a `Tuple` type that implements the `PartialEq` trait, so I can compare two tuples with `==`
and `!=`:

```rust
#[derive(PartialEq)]
struct Tuple<T> {
    first: T,
    second: T,
}
```

By defining the derive clause, I can now compare two tuples with `==` and `!=`:

```rust
let x = Tuple { first: 1, second: 2 };
let y = Tuple { first: 1, second: 2 };
assert!(x == y);
```

The Rust compiler automatically generates the `PartialEq` implementation for my type on compile time:

```rust
impl<T: ::core::cmp::PartialEq> ::core::cmp::PartialEq for Tuple<T> {
    #[inline]
    fn eq(&self, other: &Tuple<T>) -> bool {
        match *other {
            Tuple {
                first: ref __self_1_0,
                second: ref __self_1_1,
            } => match *self {
                Tuple {
                    first: ref __self_0_0,
                    second: ref __self_0_1,
                } => (*__self_0_0) == (*__self_1_0) && (*__self_0_1) == (*__self_1_1),
            },
        }
    }
    #[inline]
    fn ne(&self, other: &Tuple<T>) -> bool {
        match *other {
            Tuple {
                first: ref __self_1_0,
                second: ref __self_1_1,
            } => match *self {
                Tuple {
                    first: ref __self_0_0,
                    second: ref __self_0_1,
                } => (*__self_0_0) != (*__self_1_0) || (*__self_0_1) != (*__self_1_1),
            },
        }
    }
}
```

# Pattern matching

Another cool feature of Rust is pattern matching.

```rust
struct Color(f64, f64, f64);

impl Color{
    fn as_string(self) -> String {
        let Self(red, green, blue) = self;
        format!("red: {}, green: {}, blue: {}", red, green, blue)
    }
}
```

In this example, I have a struct `Color` that has three fields: `red`, `green` and `blue`. When calling `as_string` on
this struct,
the three fields are extracted into the local variables `red`, `green` and `blue`, and formatted into a string.
This is a minimal example, but it shows how pattern matching can be used to reduce code.

-------

Not only can you use it in cases like this, but also for matching against enum variants:

```rust
enum WifiState {
    Disconnected,
    Connected { ssid: String },
    Error(i64),
}
```

This enumeration has 3 variants: `Disconnected`, `Connected` and `Error`, but `Connected` has a field `ssid` that
represents the
SSID of the network.

When calling `get_connection_ssid` on this enum, the variant is extracted into the local variable `state`, and the
fields are extracted
I can create a new method called `get_connection_ssid` that returns the SSID of the connection if it's connected:

```rust
impl WifiState {
    fn get_connection_ssid(&self) -> Option<String> {
        match self {
            Self::Connected { ssid } => Some(ssid.clone()),
            _ => None
        }
    }
}
```

# Option

In **safe** Rust, there's no way to have null pointer dereferences. There's no way to **create** a null pointer.
This is by design, and I think it's fantastic.
Instead, you can use the `Option` type to define that there's no value.

```rust
let x_has_value = Some(1);
let x_has_no_value = None;
```

If you want to use the value inside the `Option`, you must unwrap it first. It can be done using Pattern matching:

```rust
let x_has_value = Some(1);

match x_has_value {
    Some(x) => println!("x has value {}", x),
    None => println!("x has no value"),
}
```

It can also be checked with `if let` statements:

```rust
let x_has_value = Some(1);

if let Some(x) = x_has_value {
    println!("x has value {}", x);
} else {
    println!("x has no value");
}
```

Which is the same as:

```rust
let x_has_value = Some(1);

if x_has_value.is_some() {
    let x = x_has_value.unwrap();
    println!("x has value {}", x);
} else {
    println!("x has no value");
}
```

# Result and the ? operator

In Go, normally, the functions return a tuple of the value and an error, and the error must be checked all the time:

```go
result, err := doSomething()
if err != nil {
	return err
}
fmt.Println(result)
```

I find this to be extremely verbose, and sometimes I find myself writing production code consisting of 50% error
checking. In Rust, methods that can fail return a `Result` type.

```rust
fn do_something() -> Result<i32, SomeCustomError>
```

The equivalent code in rust from the Go code would be:

```rust
let computation = do_something();
if let Ok(result) = computation {
    println!("computation value: {}", result);
} else if let Err(error) = computation {
    return Err(error.into());
}
```

This still is very verbose when using `if let` and pattern matching. 
Hopefully, we have the `?` operator to return the error to the caller:

```rust
let result = do_something()?;
println!("computation value: {}", result);
```

You can even write:

```rust
println!("computation value: {}", do_something()?);
```

Isn't it great? 🤓

# Iterators

The [Iterator pattern](https://en.wikipedia.org/wiki/Iterator) is a common design pattern in computer science that
allows traversing a container independently of the type performing some other operations on the elements.

In Rust, you can implement your own Iterator very easily by just implementing
the [`Iterator`](https://doc.rust-lang.org/std/iter/trait.Iterator.html) trait. In particular, you only need to
implement
the [```Iterator::next(&mut self) -> Option<Self::Item>```](https://doc.rust-lang.org/std/iter/trait.Iterator.html#tymethod.next)
method.
The rest of the methods to work with iterators
are [implemented for you](https://doc.rust-lang.org/std/iter/trait.Iterator.html#provided-methods), based on the first
one.


Working in Go, I've been missing this pattern quite a lot. In Go, you always use `for` to iterate over things,
whether they are a slice, a map, or a channel. 

So, in the end, you always end up doing: 

```go
for index, value := range someCollection {
	// use index and/or value
}
```

That's it. You need to implement everything yourself.
Do you want to retrieve the sum of the first three elements in a slice higher than 0? There you go:

```go
sum := 0
elementsLeftToSum := 3
for _, element := range someSlice {
    if element > 0 {
        sum += element
        elementsLeftToSum--
        if elementsLeftToSum == 0 {
            break
        }
    }
}
```

Do you want to do the same in Rust? Easy:

```rust
some_slice.iter().filter(|element| **element > 0).take(3).sum()
```

Needless to say, this is a time saver and ends up in better maintainable code.

# Ownership, Borrowing and Lifetimes

For me, this is the killer feature in Rust. This is what makes this programming language so
powerful, making it more secure than other languages while maintaining performance without
a Garbage Collector.

Every variable has an owner. When you declare a new value of a type, the variable that
holds it is the owner of the value. There can be only **one** owner at the same simultaneously, and when
the owner goes out of the scope, the value is dropped.

Now, in order to use it, you need to pass this value around, but there are two main ways of doing so:

- Giving away ownership to another variable.
- Lending the value to another variable that will return the ownership. This is **borrowing**, and it's done by sending a reference to the actual value.

Let's say you have this code:

```rust
let my_var = String::new("AwesomeValue");
do_something_owning(my_var);
```

The function `do_something_owning` is acquiring ownership of the String `"AwesomeValue"`.
From this function call onwards, you cannot use `my_var` anymore because it is no longer valid,
and trying to use it again will end up in a compilation error.

Do you want to call it multiple times? Do not give it ownership; just **borrow it**:

```rust
let my_var = String::new("AwesomeValue");
do_something_borrowing(&my_var);
do_something_borrowing(&my_var);
do_something_borrowing(&my_var);
```

Looking at this code example, it's clear that we are not sending the value itself, but a **reference** 
to the actual value _(A reference in Rust is like a pointer in C that's known to always be valid and
correctly aligned)_.

So, when sending the reference to the value, we are borrowing it. But then, another set of rules 
enters the stage.
At any given time, you can have either:
- One **mutable** reference
- Any number of **immutable** references.

References are always checked with the corresponding [lifetimes](https://en.wikipedia.org/wiki/Variable_(computer_science)#Scope_and_extent) of the
variables they point to.
In C this code compiles **but is not correct**:

```c
int* evil_function_returning_dangling() {
    int my_var = 42;
    return &my_var;
}
```

When executing it, it's (obviously) killed by the OS with `Segmentation fault (core dumped)` because
dereferencing a dangling pointer is [Undefined Behavior](https://en.wikipedia.org/wiki/Undefined_behavior).

Same code in Rust:

```rust
fn evil_function_returning_dangling() -> &i32 {
    let my_var = 42;
    return &my_var;
}
```

It fails to compile with the following error:

```
error[E0515]: cannot return reference to local variable `my_var`
 --> src/main.rs:3:12
  |
3 |     return &my_var;
  |            ^^^^^^^ returns a reference to data owned by the current function

For more information about this error, try `rustc --explain E0515`.
```

The code will never compile because it's not valid. More info at [E0515](https://doc.rust-lang.org/error_codes/E0515.html).

This prevents the existence of [data races](https://en.wikipedia.org/wiki/Race_condition#Data_race),
[null pointers](https://en.wikipedia.org/wiki/Null_pointer), and [dangling pointers](https://en.wikipedia.org/wiki/Dangling_pointer)
at compile time.

