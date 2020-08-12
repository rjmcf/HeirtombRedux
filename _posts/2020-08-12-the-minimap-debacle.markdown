---
layout: post
title:  "The Minimap Debacle"
date:   2020-08-12 17:00:00 +0100
---

It is a very particular kind of pain that comes with deleting hours worth of work, even if you know it's for the best.

It's a problem I have had to face in my day job as well. It's not any more fun there. I can rationalise it as "making progress towards the correct solution", but it still hurts to hit that delete key.

After the Game States work was finished, the next thing I wanted to do was start working on the World Map. There are a few reasons for this:

* It's hard to implement anything else without a world to put it in!
* Parts of the World Map work are examples of infrastructure that could be neglected early on, making it a big problem later on, like I talked about last time
* It's a good way to test some new debug tools!

{% details_section Definition: Debug %}
"Debug" is quite a strange word now I think about it. It was first used as a verb, so that "I need to debug this code" means "I need to remove the bugs from this code". A "bug" here is a problem, error, or mistake.

(I was saddened to learn that [the moth story][moth-story] is not the first time the word was used in this context, but it does explain why the term caught on. It didn't catch on, it was already a term in use.)

The strange part for me is that the word is now also used as a noun. "Debug" refers to any additional information that may be added to a program to help the debugging process. Debug helps you debug. Thanks English, this is why noone likes you.

[moth-story]: https://www.computerworld.com/article/2515435/moth-in-the-machine--debugging-the-origins-of--bug-.html
{% enddetails_section %}

A few days ago, Max told me that Unity provides a debugging tool called [IMGUI][imgui], which lets you very easily draw debug information on the screen. I was excited to hear about this, because I've used a very similar tool before, and know just how powerful it can be. One of the great things about it is that it lets you definitively separate out the debug related code, so it can be easily removed later. This is super useful, and in particular I was sure it would prevent the issue that caused me so much pain during the jam, where debug code got mixed up in the real stuff and accidentally took out what looked like 75% of the graphics.

I started off by adding some debug to the GameStates I made last week:

{% include captioned_image.html url="assets/images/MinimapDebacle/GameStateDebug-Optimise1.gif" width="400" description="An animated gif showing a little window where text shows the state of the game changing from MainMenu to Playing to Paused etc" caption="I am never using print statements ever again" %}

That this was so easy was a good sign to me! Now onto something more challenging.

Like last time, the world map is going to be a grid of square shaped things which I will call "tiles". Each tile can hold stuff in it, and before we have models to represent that stuff, we need another way of representing what the tiles contain. Last time, as I documented, I coloured the actual tiles themselves to show what was in them, and this caused huge problems later. This time, I hope to keep the debug functionality completely separate from the game functionality. If I can make a debug representation of the map, then I can colour the tiles in IMGUI to show what's in them, and leave the actual map tile completely untouched.

Now, a difference between last time and this time is that we're considering having different elevations for our tiles. In order to show this on the IMGUI debug map, I was thinking that we would need full 3D perspective drawings of the map, so you could see the elevation of each tile.

{% include captioned_image.html url="assets/images/MinimapDebacle/bar_chart.png" width="600" description="A picture of a 3D excel bar chart, showing a grid of bars of different heights and colours" caption="Maybe something like this, but not a goddamn excel scientific bar chart" %}

This, I thought, would be *somewhat* hard to do, but should be possible. I've seen something similar done before in something very like IMGUI, so how hard can it be? Oh, how we love foreshadowing and dramatic irony around here.

First off, before I could realise my wildest technicoloured bar chart dreams, I had to start small. I had to be able to draw straight lines. I wasn't entirely sure about how to go about this, but managed to find [an example][line-draw-eg] of someone having done it before me. There was a lot of code here, but the main insight for me was how to draw a diagonal line. Imagine you had to draw a diagonal line on paper, and for some reason you can only draw horizontal lines. The easiest way to do this is to rotate the paper you're drawing on, and then draw your horizontal line. When you turn the paper back to normal, the line ends up diagonal.

{% details_section Technical Details %}
Lemme walk through the code for that here:

{% highlight c# %}
Texture2D lineTex = new Texture2D (1, 1);  
Matrix4x4 matrixBackup = GUI.matrix;
{% endhighlight %}

Making a new texture for every line that gets drawn is horrible, but we can optimise that by creating one up front and using that for every line.

{% highlight c# %}
float angle = Mathf.Atan2 (pointB.y - pointA.y, pointB.x - pointA.x) * 180f / Mathf.PI;
{% endhighlight %}

This represents the angle that we are going to rotate our horizontal line by, converted from radians into degrees.

{% highlight c# %}
GUIUtility.RotateAroundPivot (angle, pointA);
GUI.DrawTexture (new Rect (pointA.x, pointA.y, length, 8), lineTex);
GUI.matrix = matrixBackup;  
{% endhighlight %}

Here, we do the rotation (what I called "rotating the paper" above), then draw a horizontal line of the predetermined width (8) and the precalculated length (not shown here). By restoring the backup matrix, we are essentially turning the paper back to normal again.
{% enddetails_section %}

This felt like quite a natural solution to me, so I tried it out. Well, it had some interesting results...

{% include captioned_image.html url="assets/images/MinimapDebacle/RotationFail-Optimise1.gif" width="600" description="Shows a red line moving in completely different directions to where the map is being moved" caption="The red line is vertical (as intended), but should be in the top left corner of the dark grey square" %}

Drat. Well, this is what you get for ripping off someone else's work wholesale.

So I decided to start from scratch, making sure I understood every part of the process as I went. I learned a lot about different parts of the tools I am using, which was good, and managed to get individual points displaying very reliably. Walk before you can run and all that.

I started working on the lines again, confident that I'd get it right this time, and the exact same thing happened! I did some further investigation, and discovered that something to do with how we were scaling up the GUI was causing the rotation to just happen around the wrong point. I tried every combination of scales and rotations and transformations I could think of, but nothing got it working. I went to bed that night having accomplished very little.

The next evening (I'm only working on this in my spare time of course), I went back and tried every combination I could think of again, just in case I had typed one incorrectly or something. Finally I realised something. I was picking pivot points (the point on the screen that the horizontal line was being rotated around) almost at random, and then just hoping they would be in the right place. What I needed to do was reverse engineer the point, that is, make it so that the line was in the right place, and then see what point we'd rotated around. The way I worked out that would let me do this was to rotate around the mouse position on the screen. I could just move the mouse until the line was in the right place, then see where the mouse was!

When I did this, I discovered that what I needed was... an incredibly simple scale. I don't know how I missed it both times I went through all the combinations. Success was bittersweet.

But it was success! Now I could start actually working on the perspective drawing!

But then I noticed something... weird.

{% include captioned_image.html url="assets/images/MinimapDebacle/ClippingIssues-Optimise1.gif" width="600" description="When the width of the window is reduced, the line disappears a little too early. When the height of the window is reduced, the line disappears much too late." %}

On the one hand, it's great that the line I'm drawing is getting clipped. On the other, I wish it wasn't getting clipped like *that*.

After a bit of research, it appears that this may be a bug in Unity itself that's been around since 2013. Yeah that's right, this is a call out post. Fix your shit, Unity. How do I @ on this thing.

The issue is caused by using Unity's clipping with Unity's rotation, it seems like if I do either or both of these things myself then we'll be fine. I try implementing my own clipping by drawing a massive texture over everything that's inside the window that isn't the map, but this absolutely destroys the frame rate, making it hard to work with. I'm getting frustrated at this point, and can't be bothered to pursue this method.

Ok, if I still want to do this, I need a way of drawing a diagonal line without rotation. There are ways, there are some very classic line drawing algorithms that make diagonal lines out of many small squares (like [this one][bresenham]), but I worry that this will also tank the frame rate. I also worry that I don't really want to do this anymore. 

If I'm struggling this hard on the absolute *basics*, what's it going to be like doing the actual thing I want to do which is about four thousand times more complicated? This doesn't feel like game dev any more, not the kind I want to spend my free time doing anyway. Is there another way of doing what I want that doesn't require me to sell my soul?

Let's go back to the core problem. Naively, the map is a grid of squares, except some of these squares can be higher than others, and I need a way of showing that. Well, on the debug these squares are going to be unbelievably simple, they're just going to be a block colour, so I have space inside the square to put information. Like, I dunno, a number representing the elevation. That's easy, that solves the problem in about 15 minutes, and doesn't make me want to chuck my laptop in a lake.

{% include captioned_image.html url="assets/images/MinimapDebacle/flat_grid.png" width="400" description="A flat grid of ten by ten squares, each with the number 0 in it." caption="Job's a good'un" %}

Right, well that was a huge waste of time. 

Although, as I alluded to during this, I don't *really* think it was. I did learn lots about Unity's IMGUI that will make stuff easier going forward, and learned what sort of things to avoid doing. I think I've also learned that I need to give up sooner. Not in a defeatist kind of way, but more in a "is this really the only/best way to go about this?" kind of way. The important thing, I think, is to keep the momentum going on the game itself, rather than getting too bogged down in extraneous stuff. A good lesson to learn this early I believe!

Next time, hopefully I'll have finished off the World Map initial implementation!

[bresenham]: https://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm
[imgui]: https://docs.unity3d.com/Manual/GUIScriptingGuide.html
[line-draw-eg]: https://gist.github.com/nsdevaraj/5877269