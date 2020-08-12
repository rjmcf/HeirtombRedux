---
layout: post
title:  "Game States"
date:   2020-08-03 17:00:00 +0100
---

I'm an infrastructure nerd at heart. I just love getting stuck into some abstract system that has very little reference to the material world. It's the niche that I've found at work in my day job, and it's what I decided to start with here.

Now let's be clear, I didn't start with this kind of stuff *just* because it's my favourite! I also did it because it's something that in the past, we've tended to forget, and push back, and neglect until suddenly it's a massive problem and necessitates lots of awkward changes to account for.

During the jam, we started by implementing the basic game mechanics: the world grid, the entities, the player moving around the world, etc. This was all fine until towards the end of the time, when we realised that "uh-oh! If you get a game over you need to restart! And we don't have any easy way to do that!" So it all ended up being rushed, desperately trying to make sure that everything got deleted and recreated, so nothing was hanging over from your last attempt. Well, we're not having that this time, because I'm implementing the game state machine *first*.

First, the jargon. What do I mean by "game state machine"? Well, a "state machine" is a computer science term that refers to a sort of abstract "machine" that can transition between various "states".

(Look mom, I'm using my degree!) 

You can imagine it a bit like a flow chart. Actually, it's exactly like a flow chart. Why didn't my lecturers just describe it like a flow chart? Lousy, good for nothing degree.

If you're still not sure what I'm on about, this is best explained with an example. Let me show you what I was aiming for for this particular game:

{% include captioned_image.html url="assets/images/GameStates/initial_game_state_machine.png" width="600" description="A flowchart with labeled arrows between labeled boxes" %}

Here, the boxes represent "states" that our game can be in, and the arrows represent how you transition between those states, with the labels describing the action. So to move between the "Playing the game" state and the "Pause Menu" state, the player has to "Pause", and to move back, the player has to "Unpause".

The "Start" state just tells you where to start reading from. A few things to note: 
* There are plenty of loops in this flowchart! This is by design, players can go round and round these states as much as they need. They can pause and unpause as often as they like, fail and start over to their hearts' content.
* Most state machines (especially those used for pattern matching etc) will have an "output" or "final" state. We don't need that here, since players can just quit the game at any time, and there's no point linking every single state to some extra "Game Closed" state
* The transition between "Start" and "Main Menu" has no label. This is just to show that there's no specific action the player needs to take to get to the Main Menu, they just click on the icon and they're straight in.
* This is pretty general! Given how much trouble we've had with this in the past, this may be a candidate for some utility code that we can just reuse whenever we start a new project.

As with all these kinds of things, I'm not instructing you on how you *should* be doing this sort of thing, just explaining how I'm choosing to do it, and hopefully explaining why it made sense to me. Leave a comment if you have a better suggestion. That was a joke, there's no comment section on this thing. Not yet anyway... Hey, you can always tweet at me if you have a burning desire to tell me I'm an idiot. I'm sure I'd love to hear from you.

But geneuinely, if you want to see more detail, see some actual code, or want me to change anything about how I'm doing these, please do let me know! Links to social things are at the bottom of every page.
