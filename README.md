# Feeling Cagey?

This is a really stupid Ruby application which pulls images with a certain tag from the Instagram API and superimposes Nicolas Cage's face onto them using OpenCV. Here's how to make it work on your machine:

## Getting started

Have a hearty and nutritious breakfast. There's no point in coding on an empty stomach.

## Prerequisites

- Ruby (I've tested it on >= 2.0.0, but in theory it should work with 1.9.x)
- OpenCV (`brew tap homebrew/science && brew install opencv` if you're on OS X)
- MongoDB (for added web scale; did you know this app is valued at $1.2bn too?)
- A Pusher account (this handles the *highly important* real-time addition of cage)

## Install the app

Clone the source and run `bundle install` to install those juicy gems. After this, you're going to need to create a .env file with some configuration options in - 6 of them to be precise. Hopefully it'll look a bit like this.

    TAG=selfie
    INSTAGRAM_CLIENT_ID=YOUR_INSTAGRAM_CLIENT_ID
    INSTAGRAM_CLIENT_SECRET=YOUR_INSTAGRAM_CLIENT_SECRET
    MONGODB_URL="mongodb://mongodb_user:mongodb_password@your_mongodb_host:mongodb_port/mongodb_database"
    PUSHER_KEY=YOUR_PUSHER_KEY
    PUSHER_URL="http://key:secret@api.pusherapp.com/apps/app_id"

The app is split up into two parts, the web interface (`lib/app.rb`) and the Instagram poller (`lib/update.rb`).

### Web Interface

This more or less just serves up the latest media from MongoDB to /photos.json with the dimensions and positioning of the face(s) on it. We don't actually composite the photos in real time (as that would take an eternity and use a boat-load of disk space) - we just save the co-ordinates of the detected faces and render a skewed image via CSS thus allowing the app to remain light and springy, much like a nice Victoria sponge.

Simply run `bundle exec rackup` and the web interface will pop up on port 9292. It's shockingly unimpressive.

### Instagram Poller

This is the script which does all the heavy lifting - it polls Instagram (you don't say), downloads any new media and attempts to detect faces in it. It'll wait for 10 seconds after running through all the images before hitting Instagram again in an attempt to not hit any rate limits. There's a rationale behind doing this instead of using Instagram's webhooks which I'll outline in the FAQs section on the off chance you're interested.

To get this particular party started run `bundle exec rake`. It's fairly CPU intensive so I'd recommend killing it if you're not using it.

## FAQs

Like you've actually made it this far down the page.

### Why?

Why not?

### Why don't you use Instagram's real-time callback functionality?

Two reasons:

- It's difficult to get it to work in a development environment (even using localtunnel et al) consistently, and I'm lazy
- If you're subscribed to an extremely popular tag (say 'selfie') then IG will actually start hitting your application so frequently that the subsequent calls you make to their API will get you rate limited in about 10 minutes, rendering the app useless

### Why aren't there any tests?

It's an app with about 200 lines of code that superimposes photos of Nicolas Cage onto Instagram selfies. I'm all for TDD, but really?

## Contributing

- Make a pull request
- Shout at me via an issue or email (josh@joshmcmillan.co.uk)
- Watch The Wicker Man

## License

MIT