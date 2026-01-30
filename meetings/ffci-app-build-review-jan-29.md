# FFCI: App Build Review - January 29, 2026

**Meeting Details:**
- **Date:** January 29, 2026
- **Recording ID:** 118256981
- **URL:** https://fathom.video/calls/548433831
- **Recorded by:** Mike Kaczorowski (ELT)

---

## Summary

## FFCI Mobile App Review and Handoff

### Overview

[Anthony demoed the nearly complete Firefighters for Christ mobile app running on an Android emulator (iOS at feature parity). The app pulls all content from the new website, featuring a home screen with Featured items and scrollable Resources, bottom tab navigation (Home, Resources, Media, Connect), app-wide search, and updated branding (Maltese cross icon/logo). He showed how app content is managed via website pages, a dedicated “Mobile” section, and “Mobile Settings” for featured tiles and quick tasks. Media playback, category structure plans, and form handling (via web) were demonstrated.](https://fathom.video/share/7RdRMV1c5woTuDB-yzS8W1Hh-zMYdxFw?tab=summary&timestamp=522.0)

### Benefits

  - [Single source of truth: App content fully managed from the website, reducing duplicate work and ensuring consistency.](https://fathom.video/share/7RdRMV1c5woTuDB-yzS8W1Hh-zMYdxFw?tab=summary&timestamp=663.0)
  - [Flexible curation: Featured section surfaces timely or priority content; Resources grid holds evergreen items.](https://fathom.video/share/7RdRMV1c5woTuDB-yzS8W1Hh-zMYdxFw?tab=summary&timestamp=1489.0)
  - [Faster iteration: “Mobile Settings” panel simplifies changing labels, images, and links without code changes.](https://fathom.video/share/7RdRMV1c5woTuDB-yzS8W1Hh-zMYdxFw?tab=summary&timestamp=1354.0)
  - [Improved UX: App-wide search, polished styling aligned with site branding, and bottom navigation tailored for core actions (e.g., Connect, Give).](https://fathom.video/share/7RdRMV1c5woTuDB-yzS8W1Hh-zMYdxFw?tab=summary&timestamp=2381.0)

### Process

  - [Content architecture: App pages mirror website pages; a “Mobile” folder holds app-optimized pages and subpages.](https://fathom.video/share/7RdRMV1c5woTuDB-yzS8W1Hh-zMYdxFw?tab=summary&timestamp=663.0)
  - [Design/system setup: Primary color and typography carry through to app components; featured tiles and quick tasks configured in Mobile Settings.](https://fathom.video/share/7RdRMV1c5woTuDB-yzS8W1Hh-zMYdxFw?tab=summary&timestamp=1607.0)
  - [Media approach: Initial media list seeded by top-downloads from Subsplash analytics; future items added to a Media Resources collection with categories.](https://fathom.video/share/7RdRMV1c5woTuDB-yzS8W1Hh-zMYdxFw?tab=summary&timestamp=1133.0)
  - [Test builds: Using TestFlight (iOS) and Google Play internal testing (Android) for device QA before App Store submission.](https://fathom.video/share/7RdRMV1c5woTuDB-yzS8W1Hh-zMYdxFw?tab=summary&timestamp=2414.0)

### Blockers and concerns

  - [App transfer from Subsplash: Ideal path is a store-to-store publisher transfer to retain installs/reviews and auto-update users; requires Subsplash to initiate and may be unlikely. Fallback is launching a new app and sunsetting the old.](https://fathom.video/share/7RdRMV1c5woTuDB-yzS8W1Hh-zMYdxFw?tab=summary&timestamp=3991.0)
  - [Search index/SEO for app-only pages: App pages must be published on the website; team to consider noindex or separation to avoid cluttering web search results.](https://fathom.video/share/7RdRMV1c5woTuDB-yzS8W1Hh-zMYdxFw?tab=summary&timestamp=795.0)
  - [Large/third-party forms: Membership (ChurchSuite) and some forms will open in the browser; native in-app forms would be a future enhancement and require API integration.](https://fathom.video/share/7RdRMV1c5woTuDB-yzS8W1Hh-zMYdxFw?tab=summary&timestamp=1731.0)
  - [QR code: Current QR points to a Subsplash URL outside FFCI control; will need a new code/URL strategy at launch.](https://fathom.video/share/7RdRMV1c5woTuDB-yzS8W1Hh-zMYdxFw?tab=summary&timestamp=2924.0)
  - [Tab count/labels: Five tabs may feel cramped depending on label length; needs testing with short labels.](https://fathom.video/share/7RdRMV1c5woTuDB-yzS8W1Hh-zMYdxFw?tab=summary&timestamp=2261.0)

### Q\&A

#### How do we make app edits and keep web/app content distinct?

  - [Edits are made on the corresponding website page. For app-optimized content, create app-specific versions (e.g., duplicate “Prayer Request” without explanatory text) under the “Mobile” folder and link those via Mobile Settings. Consider using noindex or CSS to hide “fluff” on mobile views. App pages must be published on the site for the app to read them, but you wouldn’t link to them on the site.](https://fathom.video/share/7RdRMV1c5woTuDB-yzS8W1Hh-zMYdxFw?tab=summary&timestamp=2040.0)

#### Can media be organized by categories in the app?

  - [Yes. The app can surface a Media Resources page that lists categories (e.g., Encouragement, Marriage) from the website’s collection. Featured can highlight a collection or specific items. Files can be uploaded or linked; linking to external hosts may require testing for in-app playback.](https://fathom.video/share/7RdRMV1c5woTuDB-yzS8W1Hh-zMYdxFw?tab=summary&timestamp=960.0)

#### How will forms work in the app (Prayer, Membership, etc.)?

  - [App buttons open the device browser to the corresponding website form (same branding, quick transition). Large or external forms (e.g., ChurchSuite) remain external. Native in-app form experiences are possible later as a change request, likely requiring API integration (e.g., ChurchSuite) and multi-step UX for mobile.](https://fathom.video/share/7RdRMV1c5woTuDB-yzS8W1Hh-zMYdxFw?tab=summary&timestamp=1670.0)

#### What’s the testing process to preview the app on our phones?

  - [Anthony will add tester Apple IDs/emails to TestFlight (iOS) and emails for Google Play testing (Android). Testers install TestFlight, accept the invite, then install the FFCI test build. It behaves like a normal app for QA.](https://fathom.video/share/7RdRMV1c5woTuDB-yzS8W1Hh-zMYdxFw?tab=summary&timestamp=2414.0)

#### Can we keep five bottom navigation tabs, and what should they be?

  - [Five may fit if labels are short. Current tabs are Home, Resources, Media, Connect. Team prefers adding Give and possibly Prayer; Media could be removed from tabs and accessed via Featured/Resources. This can be adjusted and tested.](https://fathom.video/share/7RdRMV1c5woTuDB-yzS8W1Hh-zMYdxFw?tab=summary&timestamp=2261.0)

#### Will existing Subsplash app users be seamlessly migrated?

  - [Best case: Subsplash initiates an app transfer so users get an update in place, preserving installs/reviews. Anthony found it’s technically possible; cooperation from Subsplash is required. If not feasible, FFCI will launch a new app and communicate the change, turning off the old app upon account closure.](https://fathom.video/share/7RdRMV1c5woTuDB-yzS8W1Hh-zMYdxFw?tab=summary&timestamp=3991.0)

#### How should we handle the website’s App page and existing QR code?

  - [Unpublish the App page until launch to avoid sending users to the old Subsplash app. Replace the QR code with one pointing to an FFCI-controlled URL (so it can be redirected post-launch). If Subsplash transfer proceeds, existing QR likely won’t help since it’s on a Subsplash domain.](https://fathom.video/share/7RdRMV1c5woTuDB-yzS8W1Hh-zMYdxFw?tab=summary&timestamp=2627.0)

#### Can app search find any page?

  - [Yes. The in-app search queries app-available pages (sourced from the website) so users can quickly navigate without drilling through menus.](https://fathom.video/share/7RdRMV1c5woTuDB-yzS8W1Hh-zMYdxFw?tab=summary&timestamp=2381.0)

#### How do image crops, columns, and layout tweaks work on the site (impacts app too)?

  - [Use built-in crop ratios (e.g., 3:2) to standardize image sizes and adjust crop focus to avoid cut-offs. In grid layouts, adjust column counts or drag-reorder images to avoid “checkerboard” gaps. Image settings (max width, alignment, margins) help refine layout within columns. These changes reflect in app-rendered views when relevant.](https://fathom.video/share/7RdRMV1c5woTuDB-yzS8W1Hh-zMYdxFw?tab=summary&timestamp=3257.0)

#### Can we feature event recaps?

  - [Yes. On the app, use the Featured area for timely recaps. On the website, add a Recap section or column on Events, or create a dedicated section below Upcoming. Journity can also promote recaps via targeted pop-ups and drive app downloads.](https://fathom.video/share/7RdRMV1c5woTuDB-yzS8W1Hh-zMYdxFw?tab=summary&timestamp=3812.0)

#### Will Google Translate behavior affect users internationally?

  - [The site’s Google Translate service detects locale and offers relevant languages, with a bar to switch back to English. This behavior is expected and beneficial for international audiences.](https://fathom.video/share/7RdRMV1c5woTuDB-yzS8W1Hh-zMYdxFw?tab=summary&timestamp=3087.0)


---

## Transcript


**Mike Kaczorowski** (00:00:00): Thank Yeah, Robert, how are you doing, buddy?
**Robert’s iPhone** (00:00:44): Hi, Mike.
**Robert’s iPhone** (00:00:45): I'm good, Matt.
**Robert’s iPhone** (00:00:46): Have you recovered from the Philippines?
**Mike Kaczorowski** (00:00:49): Are you working under your car?
**Mike Kaczorowski** (00:00:52): What are you doing there?
**Robert’s iPhone** (00:00:53): I've been driving.
**Robert’s iPhone** (00:00:55): I'm just home from the...
**Robert’s iPhone** (00:00:56): You are in your car.
**Mike Kaczorowski** (00:00:57): You are in your car.
**Mike Kaczorowski** (00:00:58): Okay.
**Mike Kaczorowski** (00:00:59): Yeah.
**Robert’s iPhone** (00:00:59): I'm just pulling up at the house now, so I've got another meeting shortly, but hopefully I should be able to get enough out of this for you.
**Mike Kaczorowski** (00:01:10): Have you met Steve Munoz, Robert?
**Robert’s iPhone** (00:01:13): I don't think I actually have, or maybe once at the most.
**Mike Kaczorowski** (00:01:17): Steve, how you doing, buddy?
**Mike Kaczorowski** (00:01:19): Hey, Mike.
**Steve Munoz** (00:01:20): Hello, Robert.
**Steve Munoz** (00:01:22): Steve.
**Robert’s iPhone** (00:01:23): Steve, he's our mobile app guy, working with Hannah and the team.
**Steve Munoz** (00:01:28): I'm not sure if we met Robert, unless it was at Hume last year.
**Steve Munoz** (00:01:33): It's 10 hours.
**Robert’s iPhone** (00:01:35): No, wasn't there.
**Robert’s iPhone** (00:01:36): Last year was the year before.
**Mike Kaczorowski** (00:01:40): Steve works in Arizona.
**Mike Kaczorowski** (00:01:42): Is it Peoria, Steve?
**Mike Kaczorowski** (00:01:44): Yeah, Peoria Fire Department.
**Mike Kaczorowski** (00:01:47): Hi, Mike.
**Mike Kaczorowski** (00:01:48): Hey, Mike.
**Mike Kaczorowski** (00:01:49): How are you guys?
**Mike Kaczorowski** (00:01:50): Good.
**Mike Kaczorowski** (00:01:51): We got Robert Blair all the way from Northern Ireland on the call here.
**Mike Kaczorowski** (00:01:55): Excellent.
**Mike Kaczorowski** (00:01:56): And Steve Munoz, who's kind of the guy that's been working on...
**Mike Kaczorowski** (00:01:59): On our mobile app, you know, with SubSplash, so we wanted to make sure he started to get a chance to see what's going on here, too.
**Mike Kaczorowski** (00:02:06): Excellent.
**Mike Kaczorowski** (00:02:07): Nice to meet you, Steve.
**Mike Kaczorowski** (00:02:08): Thanks for being on the call.
**Mike Kaczorowski** (00:02:09): Appreciate it.
**Steve Munoz** (00:02:10): Nice to meet you, Mike.
**Mike Kaczorowski** (00:02:15): What you here?
**Mike Kaczorowski** (00:02:16): I don't think we're...
**Mike Kaczorowski** (00:02:17): Oh, Adam might be coming on.
**Mike Kaczorowski** (00:02:19): But, Steve, just by way of introduction, my name is Mike Kaczorowski, and I've been with Five Q for about three years.
**Mike Kaczorowski** (00:02:26): I spoke as a director of operations, specifically of our processes, but for the purposes of you guys, really serving as the project manager for your website and app build.
**Mike Kaczorowski** (00:02:38): And then Adam just came on.
**Mike Kaczorowski** (00:02:41): He's been working on your website, and Anthony is our lead dev to working through your app.
**Mike Kaczorowski** (00:02:46): So, looking today, as Mike already said, looking today at just reviewing the app, and it's actually in a really good spot right now.
**Mike Kaczorowski** (00:02:56): And excited to pass this off to you guys today.
**Mike Kaczorowski** (00:02:59): So, thanks.
**Mike Kaczorowski** (00:03:00): Steve, do you mind just taking a quick minute to introduce yourself to our team?
**Steve Munoz** (00:03:05): Yeah, absolutely.
**Steve Munoz** (00:03:06): My name's Steve.
**Steve Munoz** (00:03:08): Steve Munoz there.
**Steve Munoz** (00:03:09): I've been with Firefighters for Christ for now, I mean, in total, about five years or so.
**Steve Munoz** (00:03:15): As far as handling the app, I would say a little bit over a year.
**Steve Munoz** (00:03:20): So kind of when I got the, when I was, you know, took over the responsibility of doing the app, Victor, which was the guy that previously held the app, he did a lot of the groundwork for it.
**Steve Munoz** (00:03:30): So I kind of walked into this place where it was just learning the app on the go.
**Steve Munoz** (00:03:36): You know, I think I did one page on there, which was like a welcome page and just kind of getting people to subscribe to our actual like membership page, not the app, because it was kind of two different things.
**Steve Munoz** (00:03:46): So a couple of things that I did there.
**Steve Munoz** (00:03:49): And then, yeah, just, you know, other things that we learned along the way, like licensing and stuff like that from keeping the app in the app store.
**Steve Munoz** (00:03:57): But yeah, I work.
**Steve Munoz** (00:03:59): Fire Department.
**Steve Munoz** (00:04:01): That's kind of how I got plugged into Firefighters for Christ, obviously.
**Mike Kaczorowski** (00:04:05): And, yeah, that's a little bit about me.
**Mike Kaczorowski** (00:04:08): Perfect.
**Mike Kaczorowski** (00:04:08): Where do you live, Steve?
**Mike Kaczorowski** (00:04:09): I'm in Buckeye, Arizona.
**Mike Kaczorowski** (00:04:12): Okay, great.
**Mike Kaczorowski** (00:04:13): Awesome.
**Mike Kaczorowski** (00:04:14): Your weather is probably much warmer than mine is right now.
**Mike Kaczorowski** (00:04:17): I'm in Northeast Ohio, so it's about five degrees outside right now, and I got a couple feet of snow on the ground.
**Mike Kaczorowski** (00:04:24): Oh, yeah, yeah.
**Mike Kaczorowski** (00:04:25): A lot nicer weather out here.
**Steve Munoz** (00:04:27): You still see people in shorts and T-shirts.
**Steve Munoz** (00:04:30): I love it.
**Mike Kaczorowski** (00:04:32): Mike, for Steve's purposes, do you want me to set him up with a user account on if he's going to be making adjustments to the app?
**Mike Kaczorowski** (00:04:39): Anthony, I'm assuming if I just set him up with a user on the back end of the MIP, he should be able to make app updates.
**Anthony Elliott** (00:04:47): Yeah, that's all that's required.
**Mike Kaczorowski** (00:04:49): Okay.
**Mike Kaczorowski** (00:04:50): Yeah, let's get Steve included, plugged in there, so we get a workflow going on the app side of this thing eventually as well.
**Mike Kaczorowski** (00:04:56): Great.
**Mike Kaczorowski** (00:04:56): That'll be where he's helping out.
**Mike Kaczorowski** (00:04:59): Yep, I can say.
**Mike Kaczorowski** (00:04:59): I'm you up right now, Steve, while we're on the call.
**Mike Kaczorowski** (00:05:01): I'm going to pass it over to Anthony.
**Mike Kaczorowski** (00:05:03): But I do, before we get off the call today, I want to make sure you can get access into the back end.
**Mike Kaczorowski** (00:05:07): And when we refer to the back end, you'll be able to make edits to the app, but you'll also have access to the website as a whole, too.
**Mike Kaczorowski** (00:05:15): So just kind of a call out there.
**Mike Kaczorowski** (00:05:16): Just be careful.
**Mike Kaczorowski** (00:05:18): We want to make sure that you understand what you're doing before we get you in there.
**Mike Kaczorowski** (00:05:24): Yeah, and we'll have some.
**Mike Kaczorowski** (00:05:25): We'll develop some processes internally for that.
**Mike Kaczorowski** (00:05:28): But real quick, Mike, can you record this for us, please?
**Mike Kaczorowski** (00:05:31): Yep, it is recording right now.
**Mike Kaczorowski** (00:05:33): I got my Fathom note.
**Mike Kaczorowski** (00:05:33): Okay, got my Fathom note taker.
**Mike Kaczorowski** (00:05:37): Hannah would like to see it eventually.
**Mike Kaczorowski** (00:05:38): She's not going to be able to make it today, so.
**Mike Kaczorowski** (00:05:40): Yep, perfect.
**Mike Kaczorowski** (00:05:41): And we're close.
**Mike Kaczorowski** (00:05:41): We're close on the website, and the app's much further along than I anticipated at this point.
**Mike Kaczorowski** (00:05:45): So we're really excited about everything going on.
**Mike Kaczorowski** (00:05:48): And thanks for getting that last bit of feedback in, Mike.
**Mike Kaczorowski** (00:05:51): know, like I said, we're pretty close on implementing that.
**Mike Kaczorowski** (00:05:55): And, yeah, I'll pass it off to Anthony.
**Anthony Elliott** (00:05:59): Yeah, thanks.
**Anthony Elliott** (00:06:00): Mike, so yeah, Mike Belkin, recapping what we talked, the last time you've seen it, we had kind of a quick hit and a featured section.
**Anthony Elliott** (00:06:13): It wasn't obvious where things were scrolling, so I'll show this.
**Anthony Elliott** (00:06:17): I'm going to show Android, but iOS is, I've been doing them the same, so iOS is on par.
**Anthony Elliott** (00:06:26): And also, do have, Mike K., if you can remind me, I have, I need email addresses to put into Google Play for anyone who has an Android or iOS.
**Anthony Elliott** (00:06:40): I can, I'll add you guys in so you guys can get a test build before this goes live on App Stores.
**Mike Kaczorowski** (00:06:46): So that way you can...
**Mike Kaczorowski** (00:06:47): Email addresses of anybody that you want to have, that want to have access to a test build for QA?
**Anthony Elliott** (00:06:53): Yeah, that way you guys can actually see it on your own phones.
**Mike Kaczorowski** (00:06:58): Yeah, Mike off the top of...
**Mike Kaczorowski** (00:07:00): Do you know who, I mean, I've got email addresses of most everybody, but as far as who you want to be able to access the test build directly from their phone, who would you like me to pass along, but Anthony has set that up.
**Mike Kaczorowski** (00:07:12): I think it would just be, you know, myself, Robert, Steve, Hannah.
**Mike Kaczorowski** (00:07:17): Okay, perfect.
**Mike Kaczorowski** (00:07:18): Start with that, and if there's anybody else, we'll let you know.
**Mike Kaczorowski** (00:07:22): Excellent.
**Mike Kaczorowski** (00:07:22): And are you guys familiar with the testing process, like test builds at all?
**Mike Kaczorowski** (00:07:27): I'm not.
**Mike Kaczorowski** (00:07:28): Okay, so Anthony, we'll just need to be given clear instructions on what's going to need to happen on the test flight.
**Anthony Elliott** (00:07:35): you going to use test flight?
**Anthony Elliott** (00:07:36): Yeah, yeah, I'll use test flight for iOS.
**Anthony Elliott** (00:07:39): Mike Bell, you have iPhone or Android?
**Mike Kaczorowski** (00:07:42): I'm iPhone.
**Mike Kaczorowski** (00:07:43): I don't, Robert, Steve, what are you guys?
**Robert’s iPhone** (00:07:47): I'm iPhone, Robert.
**Robert’s iPhone** (00:07:48): iPhone.
**Steve Munoz** (00:07:49): Okay.
**Anthony Elliott** (00:07:50): Yeah, I don't know that we have.
**Mike Kaczorowski** (00:07:52): I know we, if you want somebody, I can poll some of our folks and see if we have an Android user.
**Mike Kaczorowski** (00:07:57): I'm sure we do.
**Mike Kaczorowski** (00:07:58): I don't know.
**Mike Kaczorowski** (00:07:59): I don't know.
**Mike Kaczorowski** (00:07:59): I don't
**Mike Kaczorowski** (00:08:00): I mean, our, you know, comm team.
**Mike Kaczorowski** (00:08:02): What's that, Steve?
**Steve Munoz** (00:08:02): Yeah, maybe Hannah did.
**Steve Munoz** (00:08:04): I remember her.
**Steve Munoz** (00:08:05): Yeah, we'll check and let you know.
**Steve Munoz** (00:08:08): All right, I'll you my highlight.
**Mike Kaczorowski** (00:08:11): We'll figure it out as far as getting the user tested on Android.
**Mike Kaczorowski** (00:08:15): It's similar to, like, how you would download an app, but you do have to go through another app called TestFlight.
**Mike Kaczorowski** (00:08:20): And so it's not too difficult, but it's just an added step.
**Mike Kaczorowski** (00:08:24): And so, Anthony, I'm sure you can kind of walk them through what will need to happen to test it on their own devices.
**Anthony Elliott** (00:08:30): Yeah, so I'll set that up and just be expecting that.
**Anthony Elliott** (00:08:33): be good to get you guys looking at the app, and that'll be a lot better than seeing it on a screen, on my screen here.
**Anthony Elliott** (00:08:42): I will dive in.
**Anthony Elliott** (00:08:45): And I'm going to share, just because it's an app, I'm going to share a different screen than what I usually do.
**Anthony Elliott** (00:08:50): So bear with me for a minute.
**Anthony Elliott** (00:08:58): And move my Zoom bar up.
**Anthony Elliott** (00:09:00): Out of the way, okay, now obviously I'm in, I'm running this on my computer, this is not a real Android device, just calling that out, but this is the emulator, so here we open up the app, and we've added, I've added in the Maltese cross up here in the upper left, and search bar in the upper right, I don't think I had that working, I don't think I had that last time, the logo here, I'll get your feedback, especially Adam on spacing.
**Anthony Elliott** (00:09:38): Now, Mike B, we did move these around, so here now, there's featured up at the top, there's the resources on the bottom, and you can scroll through these down here, you can scroll with your finger, you can scroll with the arrow button that appears now, so that, oops, looks like it didn't go all, I thought I'd fix that one.
**Anthony Elliott** (00:09:59): Thank
**Anthony Elliott** (00:10:00): I'll get back on that on the, getting it all the way, scroll to the end.
**Anthony Elliott** (00:10:07): While I backed out there, I did get the app icon using the Maltese cross, so that's going to be a little tough to see from there, but that is the app icon there.
**Anthony Elliott** (00:10:22): Now, before leaving this page, I'll show the, especially for Steve, how you can make edits on this.
**Anthony Elliott** (00:10:30): Let me drag this over.
**Mike Kaczorowski** (00:10:32): And for Steve's benefit, Steve, just you're familiar with Subsplash, and so are you, Rob.
**Mike Kaczorowski** (00:10:41): In Subsplash, there are separate places to work on the website and the mobile app.
**Mike Kaczorowski** (00:10:48): Yeah, correct me if I'm wrong, Anthony, you can let the guys know.
**Mike Kaczorowski** (00:10:51): I think everything we're going to do on the app and the website are in the same spot as far as back end.
**Mike Kaczorowski** (00:10:57): And it's just a different app.
**Mike Kaczorowski** (00:11:01): Yeah.
**Anthony Elliott** (00:11:03): So how these apps are set up is that they're going to pull all the content from the website.
**Anthony Elliott** (00:11:10): So whatever you want to show on the app, you will actually make pages for or configure in the website.
**Anthony Elliott** (00:11:17): So I'll show that here.
**Anthony Elliott** (00:11:18): Yeah.
**Mike Kaczorowski** (00:11:19): And as we discussed before, even though we'll build a page, we don't necessarily have to publish it on the web.
**Mike Kaczorowski** (00:11:27): can be exclusive to the app using that approach, right?
**Mike Kaczorowski** (00:11:32): I'll show that.
**Anthony Elliott** (00:11:33): Yeah.
**Anthony Elliott** (00:11:34): Here.
**Anthony Elliott** (00:11:34): So I've made a page called Mobile.
**Anthony Elliott** (00:11:41): So if click onto that, here is the, this is the backend for this Connect With Us page.
**Anthony Elliott** (00:11:48): Let me show this on the app first.
**Anthony Elliott** (00:11:53): So there is a tab for, for Connect.
**Anthony Elliott** (00:11:56): We have a tab for home, a tab for resources, a tab for media.
**Anthony Elliott** (00:12:00): And Tab 4, Connect.
**Anthony Elliott** (00:12:02): So if tap on Connect, it loads the Connect with Us title.
**Anthony Elliott** (00:12:07): Welcome to the Firefighters for Christ Connection page, Proverbs 27 and 17.
**Anthony Elliott** (00:12:12): All this content is coming from this page here.
**Anthony Elliott** (00:12:19): So this is meant, it doesn't look as nice on a desktop.
**Anthony Elliott** (00:12:27): So calling out this, it does have to be published on the website in order for the app to see it.
**Anthony Elliott** (00:12:33): But you wouldn't be sending people to this URL.
**Anthony Elliott** (00:12:38): If they happen upon it, that's fine.
**Anthony Elliott** (00:12:40): It's not going to look awful.
**Anthony Elliott** (00:12:43): But for the app to work, it will pull all the content from the website there.
**Mike Kaczorowski** (00:12:47): I see.
**Mike Kaczorowski** (00:12:48): Does that make sense there, Mike?
**Mike Kaczorowski** (00:12:49): Yeah, so it could be found, but it's not something we're going to direct people to with a link or anything like that within the website.
**Mike Kaczorowski** (00:12:55): And it's not even anything they'd be able to navigate to.
**Mike Kaczorowski** (00:12:58): Yeah.
**Mike Kaczorowski** (00:13:00): Right.
**Mike Kaczorowski** (00:13:00): We'll put that link somewhere on the site.
**Mike Kaczorowski** (00:13:02): Right.
**Mike Kaczorowski** (00:13:02): Yeah.
**Mike Kaczorowski** (00:13:02): Okay.
**Mike Kaczorowski** (00:13:06): Steve, does that make sense?
**Mike Kaczorowski** (00:13:07): Yeah.
**Mike Kaczorowski** (00:13:08): far as that approach, which is slightly different than what Subsplash uses, I believe.
**Steve Munoz** (00:13:13): Yeah, that makes sense.
**Steve Munoz** (00:13:14): Anthony, quick question on that.
**Adam Hardy** (00:13:15): Will we be telling search engines not to scan these pages then?
**Adam Hardy** (00:13:21): Do we want them indexed?
**Adam Hardy** (00:13:24): If they're mobile-specific?
**Adam Hardy** (00:13:25): That is a good call.
**Anthony Elliott** (00:13:27): There's not going to be much.
**Anthony Elliott** (00:13:29): Um, so it's not a big danger if they are indexed, and you won't be linking to them.
**Anthony Elliott** (00:13:37): Um, but I will look into if I, you know, how much, um, how much can I remove on that?
**Anthony Elliott** (00:13:46): That's a good call out, Adam.
**Anthony Elliott** (00:13:47): Let me know with that.
**Anthony Elliott** (00:13:49): Okay.
**Anthony Elliott** (00:14:00): So if you wanted to ever add another page in here, I think it'd be easiest to just have this one mobile page, and you can come in here and make a sub page to this, and then once you do, then you can come into the mobile settings tab.
**Anthony Elliott** (00:14:14): So here in mobile settings, this is where you can configure the featured items, the quick tasks, shows about us.
**Anthony Elliott** (00:14:26): So between this one tab, the mobile settings, and being able to add pages, that's all that you will need to have in order to make changes on the app, which is pretty slick, all in one spot.
**Anthony Elliott** (00:14:40): So, Steve, especially for your benefit, let me go to that connect with us page and just show a small change.
**Anthony Elliott** (00:14:54): And I'll save that on the website.
**Anthony Elliott** (00:14:56): Thank you.
**Anthony Elliott** (00:15:02): There we go.
**Anthony Elliott** (00:15:03): It's saved.
**Anthony Elliott** (00:15:04): And I do need to close the app, because I do have a short cache on here, too.
**Anthony Elliott** (00:15:12): Come on.
**Anthony Elliott** (00:15:22): So if I come back to the Connects page, you can see on the text here, it says this is a small change.
**Anthony Elliott** (00:15:32): So making edits on the app is pretty simple.
**Anthony Elliott** (00:15:35): Just got to edit the website page.
**Anthony Elliott** (00:15:37): Any questions on that, Steve or Mike?
**Steve Munoz** (00:15:41): No.
**Steve Munoz** (00:15:42): That looks pretty straightforward.
**Mike Kaczorowski** (00:15:47): Yeah, we can change the picture, Steve.
**Mike Kaczorowski** (00:15:49): There's a lot of stuff.
**Mike Kaczorowski** (00:15:50): I mean, all of that is pretty straightforward and simple to do within the back end of this thing.
**Steve Munoz** (00:15:58): Let's see.
**Anthony Elliott** (00:16:00): Now, another item we talked about last time was the media, the media resources you guys have on the current app.
**Anthony Elliott** (00:16:06): I mean, as we talked, you have them on the current app, but the app, how we're making the app, it needs to pull all content from the website.
**Anthony Elliott** (00:16:14): So we added multiple resources here from the firefighters.org.
**Anthony Elliott** (00:16:22): But whatever you add here, whatever you add on the website would show up on here too.
**Anthony Elliott** (00:16:28): But you can come in here.
**Anthony Elliott** (00:16:30): So here's a message, My Identity in Christ, 74 minutes long.
**Anthony Elliott** (00:16:36): You won't be able to hear it, but it does play.
**Anthony Elliott** (00:16:40): And you can scrub through on here.
**Anthony Elliott** (00:16:47): So that was a neat addition from the last time you saw this.
**Mike Kaczorowski** (00:16:52): Yeah, and those are individual files right there.
**Mike Kaczorowski** (00:16:55): Can those be put in like categories, you know?
**Mike Kaczorowski** (00:17:00): With headings, and then have those files under that category.
**Mike Kaczorowski** (00:17:03): That's kind of how it's set up now.
**Anthony Elliott** (00:17:07): I can feature the collection.
**Anthony Elliott** (00:17:09): Adam, what can we easily do on the...
**Anthony Elliott** (00:17:13): There should be category pages in there.
**Adam Hardy** (00:17:15): I don't know if you can pull those into the media or mobile app.
**Adam Hardy** (00:17:21): But by default, collections have category pages built in.
**Adam Hardy** (00:17:31): So I don't know if you could query and pull those into the mobile app.
**Adam Hardy** (00:17:37): don't know how it is.
**Anthony Elliott** (00:17:39): Can you view them on a...
**Anthony Elliott** (00:17:41): I mean, here's the media resources page.
**Anthony Elliott** (00:17:44): Yeah.
**Adam Hardy** (00:17:45): Oh, I got you.
**Anthony Elliott** (00:17:49): Oh, sure.
**Anthony Elliott** (00:17:49): Yeah, I can.
**Anthony Elliott** (00:17:56): Yeah, so I can...
**Anthony Elliott** (00:17:57): I'll explore adding.
**Anthony Elliott** (00:18:00): And the categories, what is?
**Mike Kaczorowski** (00:18:06): Yeah, right there, Encouragement, Marriage.
**Mike Kaczorowski** (00:18:07): Those are the categories that we've, you know, a couple of ones that we have now.
**Anthony Elliott** (00:18:14): So I can have it show this page, and then it would list out these categories and any other categories that you add in the future.
**Anthony Elliott** (00:18:28): I think that'd be a good solution.
**Anthony Elliott** (00:18:40): Okay.
**Anthony Elliott** (00:18:42): I'll make that change.
**Adam Hardy** (00:18:47): Now back to the app.
**Mike Kaczorowski** (00:18:53): Just so you guys know what I did, Steve, for your sake, Robert, in prep for this, I went.
**Mike Kaczorowski** (00:19:00): Through, in our current Subsplash, where we maintain files, that's where those audio files are located.
**Mike Kaczorowski** (00:19:09): And one of the few features that Subsplash has in terms of analytics, it can tell you how many times a certain file has been downloaded, you know, as far as these audio files.
**Mike Kaczorowski** (00:19:24): So I basically pulled the ones that had been downloaded the most.
**Adam Hardy** (00:19:28): Perfect.
**Mike Kaczorowski** (00:19:28): And just, you know, just to start with, and gave those to Anthony to start with here.
**Mike Kaczorowski** (00:19:35): So, Steve, you know, this is a good chance for us to kind of purge a little bit too, you know, not necessarily put everything back in here, but the ones that are, you know, most popular and then maybe add some, you know, later as we think we need to or want to.
**Steve Munoz** (00:19:53): So when we move those, all we're going to do is we're going to add them to that page of the media file.
**Steve Munoz** (00:19:58): And then, let's go.
**Steve Munoz** (00:20:00): From here on out, they'll be categorized, so we can just put them in the correct category.
**Steve Munoz** (00:20:04): we'll add them to this collection, this media resource collection.
**Adam Hardy** (00:20:06): It's really easy.
**Adam Hardy** (00:20:07): You'll go over to the plus there and put your title in.
**Steve Munoz** (00:20:11): Okay.
**Steve Munoz** (00:20:12): You'll upload the media file.
**Adam Hardy** (00:20:14): I you could even host the audio file somewhere if you wanted to, but you can upload the file as well.
**Mike Kaczorowski** (00:20:21): Yeah, and that's one thing we may do because of the fact that the firefresh.org site has all these already.
**Adam Hardy** (00:20:27): We just might have to link to them from here.
**Adam Hardy** (00:20:29): Is that right?
**Adam Hardy** (00:20:30): Adam?
**Adam Hardy** (00:20:31): Yeah, don't know if it would play from that link or not.
**Adam Hardy** (00:20:33): We'd have to test that out.
**Mike Kaczorowski** (00:20:35): Yeah, rather than actually have the file in there.
**Mike Kaczorowski** (00:20:38): I mean, we can always do that too, but...
**Anthony Elliott** (00:20:52): It's not very obvious.
**Adam Hardy** (00:20:57): I don't know if it would play from that link.
**Adam Hardy** (00:20:59): very obvious.
**Adam Hardy** (00:20:59): it's Yes, you
**Adam Hardy** (00:21:00): Right?
**Adam Hardy** (00:21:00): Because it's embedded into the...
**Adam Hardy** (00:21:02): Yeah.
**Mike Kaczorowski** (00:21:05): Yeah, and can download the files.
**Mike Kaczorowski** (00:21:08): I mean, I don't anticipate us downloading any more than we already have, to be honest with you.
**Mike Kaczorowski** (00:21:12): think anything we're going to add going forward...
**Mike Kaczorowski** (00:21:17): Well, I mean, whatever.
**Mike Kaczorowski** (00:21:18): We are able to download the files from their site, and so if we want to put something in, we can just load it up as a file.
**Mike Kaczorowski** (00:21:24): Yeah.
**Mike Kaczorowski** (00:21:29): Like you've done here.
**Anthony Elliott** (00:21:33): And then you can also add text in here as well, and that'll show on the app.
**Mike Kaczorowski** (00:21:37): Okay.
**Mike Kaczorowski** (00:21:38): Yeah, if you want to write up a description of what the audio is about.
**Adam Hardy** (00:21:41): And then if go into the settings, that's where you'd set your category.
**Mike Kaczorowski** (00:21:44): Well, that's a good question, because one of the things we have on the website, Adam, as it relates to this, perhaps, is we get the monthly messages from the media group, and we've posted them.
**Mike Kaczorowski** (00:22:00): On our social media sites, and I'm not sure if they're posted on our app.
**Mike Kaczorowski** (00:22:04): They probably could be, but I think those are just links to the files.
**Mike Kaczorowski** (00:22:07): They're not the actual files, so we'll have to watch for that.
**Mike Kaczorowski** (00:22:11): I don't know from the website if it works any different.
**Adam Hardy** (00:22:15): Yeah, you could that too.
**Adam Hardy** (00:22:18): You could create a category for those specific audio files.
**Mike Kaczorowski** (00:22:26): Like, yeah, files of the month or whatever, you know, resources of the month or something like that.
**Adam Hardy** (00:22:34): And then I think Anthony has set it up nice so that you guys can feature whatever you want, and you can change the feature label.
**Adam Hardy** (00:22:41): Is that still correct?
**Adam Hardy** (00:22:44): Let me get back to that.
**Anthony Elliott** (00:22:48): So we've got featured items, which are the vertical ones.
**Anthony Elliott** (00:22:55): And then, so featured is here, like Chaplin Resources, Daily.
**Anthony Elliott** (00:23:00): There's some Bible search, and that's configured in this panel here.
**Anthony Elliott** (00:23:08): So Chaplain Resource, you can pick a page here.
**Anthony Elliott** (00:23:11): I don't have a custom title on that one, but I do have a custom title on, like, the media resources.
**Anthony Elliott** (00:23:18): So if you wanted to call this something different at the beginning, I call it audio sermons.
**Anthony Elliott** (00:23:22): You can put your own label in there, and it will change on the app.
**Mike Kaczorowski** (00:23:28): And your own image.
**Anthony Elliott** (00:23:32): So that'll give you guys a lot of flexibility.
**Anthony Elliott** (00:23:34): You don't have to set it right now and then never change it again.
**Mike Kaczorowski** (00:23:41): As we go along here, I'm just trying to...
**Mike Kaczorowski** (00:23:43): I want Steve to weigh in.
**Mike Kaczorowski** (00:23:46): Steve, again, the way our current app works, we have, like, if you scroll down, we have, like, what I would call categories.
**Mike Kaczorowski** (00:23:57): I think they would call those features.
**Mike Kaczorowski** (00:24:00): The items here, okay?
**Steve Munoz** (00:24:02): Okay.
**Steve Munoz** (00:24:02): Does that make sense?
**Mike Kaczorowski** (00:24:04): Yeah, it does.
**Steve Munoz** (00:24:05): So he's got three of them on here, four.
**Mike Kaczorowski** (00:24:07): We just need to decide, you know, if we want to duplicate what we got in the current app or, you know, kind of consolidate and, you know, go with fewer of these options and maybe, you know, whatever.
**Mike Kaczorowski** (00:24:21): And then occasionally, well, that's just something to start with.
**Mike Kaczorowski** (00:24:25): I mean, currently we have a welcome and about us, what we believe, events, you know, all the stuff we have there.
**Mike Kaczorowski** (00:24:34): We, they call it a featured site, a featured aspect of the app.
**Steve Munoz** (00:24:40): Yeah.
**Steve Munoz** (00:24:41): We just have it listed as a different category.
**Mike Kaczorowski** (00:24:44): So we're going to want to kind of go through that and see how we want that to play out.
**Steve Munoz** (00:24:49): So would, would featured be used mostly like kind of what's, I don't know, what's, what's popular right now, like in the moment, like, or how would.
**Mike Kaczorowski** (00:24:58): Well, that's, that's the word I'm saying.
**Mike Kaczorowski** (00:25:00): I think we have to, and for your sake, Anthony, if you look at what you're doing there, you know, like I said, we have like 12 of those different things, but it's not, it doesn't, it's more like resources.
**Mike Kaczorowski** (00:25:11): See, I think that's what we're seeing here, Steve.
**Mike Kaczorowski** (00:25:16): We would maybe have like, like he has like three or four featured, like popular ones, and the other ones would be down here as resources.
**Adam Hardy** (00:25:24): Yeah, the featured area gives you a chance to keep your, top of your mobile app, you know, fresh.
**Adam Hardy** (00:25:30): So if you need something, you want to promote something, you can add it there.
**Adam Hardy** (00:25:34): can, if there's some, a news item, or if there's an event that you want to promote, or if there's a sale going on in the store, or if there's a new resource that's available, gives you kind of an area to get that top of mind when someone visits the app.
**Steve Munoz** (00:25:49): Okay.
**Steve Munoz** (00:25:50): Yeah, I think that's how we just have to look at it.
**Mike Kaczorowski** (00:25:52): Because right now, the way it works, you know, they're just kind of set there.
**Mike Kaczorowski** (00:25:56): You know, you have to, if you want to go all the way, if the one you go to most.
**Mike Kaczorowski** (00:26:00): Let's say the store, it's all the way at the bottom.
**Mike Kaczorowski** (00:26:03): So in this case, we can put the ones we want near the top under Featured and put the rest of them down there under Resources.
**Mike Kaczorowski** (00:26:10): And then around occasionally if we want to.
**Anthony Elliott** (00:26:14): And if you have a specific item that you want to feature from the store, you can do that as well.
**Mike Kaczorowski** (00:26:21): Got it.
**Steve Munoz** (00:26:21): Okay, that makes sense.
**Steve Munoz** (00:26:22): So below where you've got Home and then Resources, does that Resource button take you to that bottom row there?
**Anthony Elliott** (00:26:30): So I wanted to, I probably need to come up with a better name for the, for here, because you actually have a real page called Resources.
**Anthony Elliott** (00:26:39): So this is showing that Resources page.
**Anthony Elliott** (00:26:42): Yeah, that's coming right off the website, okay.
**Anthony Elliott** (00:26:47): Which, calling out, since you've seen this the last time, this looks more polished here.
**Anthony Elliott** (00:26:54): We've got buttons with your primary color on it, set from the website, the headings.
**Anthony Elliott** (00:26:59): Thanks, guys.
**Anthony Elliott** (00:26:59): Thanks.
**Anthony Elliott** (00:26:59): Thanks.
**Anthony Elliott** (00:26:59): Thanks.
**Anthony Elliott** (00:27:00): It nicer.
**Anthony Elliott** (00:27:02): So this is reflected throughout the site as well.
**Anthony Elliott** (00:27:08): One callout while I was going through this is that as you have colors, so when you go from a white background with dark text and then we flip to a different color, it's good to check that.
**Anthony Elliott** (00:27:26): If you make a page and do that, just check it on the mobile app as well.
**Anthony Elliott** (00:27:30): Because sometimes it looked okay on the website and it looked different on the mobile app.
**Anthony Elliott** (00:27:38): Just because there is multiple spots where you can enter a background color on the website.
**Anthony Elliott** (00:27:44): And so it's good to double check that.
**Anthony Elliott** (00:27:50): So yeah, I'll show the prayer request button here too.
**Anthony Elliott** (00:27:53): This is one of the items I talked through Mike last time.
**Anthony Elliott** (00:27:59): Just since...
**Anthony Elliott** (00:28:00): Everything on this app is connected to the website.
**Anthony Elliott** (00:28:02): We don't have a full form here in the native app.
**Anthony Elliott** (00:28:07): Instead, people can click the button, and this is a dev site, so it might prompt me for a login here.
**Anthony Elliott** (00:28:14): So it'll open up the browser, and because we have this protected, it's asking me for our, for this here, real users won't see this.
**Anthony Elliott** (00:28:33): So clicking that button will then take them right to whatever page you want at the website that has that, just that form.
**Anthony Elliott** (00:28:41): And then so they can, they're still on their phone, they'll still be able to submit the form, but this will be going through the website.
**Anthony Elliott** (00:28:51): Now your other form, the membership application.
**Anthony Elliott** (00:28:58): Yeah.
**Anthony Elliott** (00:29:01): That is just kind of, that's a large form.
**Anthony Elliott** (00:29:04): didn't try and embed it in the app.
**Anthony Elliott** (00:29:06): again, that'll be pointing out to the website to fill that form in as well.
**Mike Kaczorowski** (00:29:14): Yeah, and I'm looking at the current app, and that's what it does now.
**Mike Kaczorowski** (00:29:17): If you find a place to do prayer requests, it takes you out to the web form for that.
**Anthony Elliott** (00:29:23): Okay.
**Mike Kaczorowski** (00:29:27): Yep, and the, yeah, what's happening with the membership, it's going to a separate application called ChurchSuite.
**Anthony Elliott** (00:29:34): Yes, yep.
**Mike Kaczorowski** (00:29:35): And that's where that goes, and it does the same thing on the mobile app.
**Mike Kaczorowski** (00:29:43): Even on the website, it takes you to that, to that site.
**Steve Munoz** (00:29:48): So, Anthony, are you saying that because it's like a, the form is from a different website, doesn't make sense to just integrate it into the app, or there's no way to have to do it?
**Steve Munoz** (00:29:59): Okay.
**Steve Munoz** (00:30:00): Or would we have to create our own?
**Anthony Elliott** (00:30:03): I mean, I, like, if you had, mainly the form is, the membership form is just so large that it's not feasible to have it on a phone that size.
**Steve Munoz** (00:30:18): Yeah.
**Anthony Elliott** (00:30:23): The forms that are native in here, like, if you make a form on your new website, that'd be something we could consider as a change request, like, if you wanted a more powerful app, if you wanted to have certain forms be fully native and fully integrated into the app, that'd be something we can build out, just not within the, not the basic app version here.
**Anthony Elliott** (00:30:47): Okay, gotcha.
**Anthony Elliott** (00:30:48): But if you're linking out to something else, then we won't be able to rebuild that.
**Anthony Elliott** (00:30:52): We just have to, we'll just keep linking out to that site.
**Robert Blair** (00:30:56): Anthony, in relation to that form that you've just...
**Robert Blair** (00:31:00): Mentioned, would that integrate with the likes of ChurchSuite to fill in that appropriate information, or is that then something else that we're going to have to then transfer across manually?
**Anthony Elliott** (00:31:15): How, yeah, how I've set it up is it will go to the website where you enter it, so you won't have to do any extra manual work to make that happen.
**Robert Blair** (00:31:24): Yeah, but if you were creating a specific form for the app, would that form that you create be able to integrate and fill in?
**Anthony Elliott** (00:31:37): That depends on, we would be open to looking into that.
**Anthony Elliott** (00:31:43): It depends on who we integrate with, ChurchSuite.
**Anthony Elliott** (00:31:47): So we'd have to be able, if they have an API, then we can, I can hit their API and send the information that way.
**Anthony Elliott** (00:31:56): Would that be something that would save you guys?
**Anthony Elliott** (00:31:58): I mean, we can't do that here in this project, but...
**Anthony Elliott** (00:32:00): Would that be something of interest to you guys down the road?
**Robert Blair** (00:32:04): That's something we'd need to discuss because currently ChurchSuite is the format that we use as our database and for all that information.
**Robert Blair** (00:32:13): And that link that you're talking about just takes them straight into the website and they fill in that information and then it's automatically into ChurchSuite.
**Robert Blair** (00:32:21): So we're not having to do anything manual there other than make it active rather than pending whenever we receive that information.
**Anthony Elliott** (00:32:31): Nice.
**Anthony Elliott** (00:32:31): So what you're saying, Robert, is if we did do extra work on the app to make a nice form on the app, we'd also have to do extra work to make sure it gets connected so there's no extra work from you guys.
**Robert Blair** (00:32:46): Yeah.
**Robert Blair** (00:32:46): Yeah.
**Anthony Elliott** (00:32:47): Good call.
**Adam Hardy** (00:32:48): There'd probably need to be some kind of API in place and then we could do like a multi-step form that would make more sense on a mobile device rather than a long scrolling form or something like that.
**Adam Hardy** (00:32:58): Okay.
**Mike Kaczorowski** (00:33:00): So, Mike K., can you put that on the parking lot thing we talked about, kind of a church suite integration for the mobile app, just as something to consider down the road?
**Mike Kaczorowski** (00:33:10): Absolutely.
**Mike Kaczorowski** (00:33:13): In the meantime, Anthony, if you go back where you have the live forms, yeah.
**Mike Kaczorowski** (00:33:20): So those four forms that you have there right now, those are native to the website, right?
**Anthony Elliott** (00:33:27): That's right.
**Mike Kaczorowski** (00:33:28): And then, and so when they show up on the app, they'll appear, it's still taking you to the website, technically, right?
**Mike Kaczorowski** (00:33:35): Yeah.
**Mike Kaczorowski** (00:33:36): But they work on the app because of the way it's all.
**Mike Kaczorowski** (00:33:41): So it actually looks pretty quick, but I clicked that prayer request button, and you can see it's actually opening up a browser.
**Mike Kaczorowski** (00:33:47): Yeah.
**Anthony Elliott** (00:33:48): It'll make more sense when you feel it here.
**Anthony Elliott** (00:33:51): So it does take you out of the app and loads up the browser, but all the branding is the same.
**Mike Kaczorowski** (00:33:57): It looks very similar.
**Anthony Elliott** (00:33:59): So here's a...
**Mike Kaczorowski** (00:34:00): Question, real quick, for the sake of this particular page.
**Mike Kaczorowski** (00:34:03): Now, I get it.
**Mike Kaczorowski** (00:34:04): We're going out to the website to pull this into the app.
**Mike Kaczorowski** (00:34:08): On the website, we have that narrative right there above the actual form, and that makes sense on the website because the form's right next to that.
**Mike Kaczorowski** (00:34:16): But in this case, you've got to go through that narrative to get to the actual form.
**Mike Kaczorowski** (00:34:21): So is there a way to modify it, you know, so when it goes to the, you know, app, it removes that?
**Mike Kaczorowski** (00:34:30): Or probably not, because it's pulling it right off that page, right?
**Anthony Elliott** (00:34:32): It's pulling the same content.
**Anthony Elliott** (00:34:35): There's a couple of ways we could do that.
**Adam Hardy** (00:34:36): We could create a separate mobile prayer request page, or we could set some parameters just on any mobile view that we're not showing that paragraph.
**Steve Munoz** (00:34:48): So I guess that brings up a good point.
**Steve Munoz** (00:34:50): Since it's pulling it from the website, if we ever wanted to make it to where the apps has less of that, you know, extra fluff, we can call it, to make it
**Steve Munoz** (00:35:00): More clean and just simple.
**Steve Munoz** (00:35:02): We would have to create two of them.
**Steve Munoz** (00:35:04): The website would have its own, and then the app would have its own.
**Steve Munoz** (00:35:07): And then we would just attach the links within that that's going to take us to the same place, which would be eventually the website.
**Steve Munoz** (00:35:14): Is that kind of what we'd have to do about?
**Steve Munoz** (00:35:15): Yeah, could make two separate.
**Anthony Elliott** (00:35:16): You could have the same form featured on two different pages.
**Anthony Elliott** (00:35:20): One page has the fluff.
**Steve Munoz** (00:35:22): One page does not have the fluff.
**Anthony Elliott** (00:35:24): That'd be an option.
**Mike Kaczorowski** (00:35:26): Yeah, I think we're going to want to look into that for stuff like this.
**Mike Kaczorowski** (00:35:28): Because that, I mean, the little heading, Submitted Protocols is perfect, but all that that's written there is, that's not necessary on the app.
**Mike Kaczorowski** (00:35:36): You know, you can go right to the form.
**Mike Kaczorowski** (00:35:38): That'd be nice.
**Mike Kaczorowski** (00:35:42): And there might be other situations like that.
**Adam Hardy** (00:35:44): You can literally duplicate that page and then move it into that mobile folder that kind of Anthony created.
**Adam Hardy** (00:35:51): Delete out that paragraph and you'd be set.
**Mike Kaczorowski** (00:35:54): Okay.
**Mike Kaczorowski** (00:35:58): Yeah, and yeah, so we don't have.
**Mike Kaczorowski** (00:36:00): Do it now, but that's something we can take care of, and that would be a good thing for us to play with and learn how to do it.
**Anthony Elliott** (00:36:07): Adam, we could talk more later, too.
**Anthony Elliott** (00:36:10): The one thing I'm thinking of is that how I got here is from the resources page.
**Adam Hardy** (00:36:18): So here, I mean, here, you've got the text here already.
**Anthony Elliott** (00:36:22): This button that says prayer request, this is also on the website.
**Anthony Elliott** (00:36:28): So I would need to, it'd be going to the same, it'd be going to the same page.
**Anthony Elliott** (00:36:33): I could have a tab, or, like, I could make a tab for a prayer request, or you could have a, you a featured, or a resource down here, or a prayer request, and that, that, that one could look, link directly to a new page on it.
**Anthony Elliott** (00:36:53): Maybe I'll show that, and, uh, you guys have some flexibility there, but I'll show that.
**Anthony Elliott** (00:36:58): you you Thank you.
**Adam Hardy** (00:37:00): What I would do, Anthony, is I would make sure that those bottom key pages were strictly built for the mobile app.
**Adam Hardy** (00:37:08): That way, any links you're sending from there, you at least have keyed into the right places, and everything's been optimized for the mobile app.
**Adam Hardy** (00:37:21): The other pages are fine if they're added in the resources area, but if we're going to feature them in that kind of that bottom main navigation, make them super, like the resources, the media, and the connect, the very bottom.
**Adam Hardy** (00:37:34): And the tabs, okay.
**Adam Hardy** (00:37:36): Simply built for the mobile app.
**Mike Kaczorowski** (00:37:41): Yeah, and on that note, I would, for the sake of some input here, Anthony, I think we would want to have, can you have five of those down there?
**Mike Kaczorowski** (00:37:53): Because we currently have five.
**Mike Kaczorowski** (00:37:54): Can you have up to five, or is there a limit?
**Anthony Elliott** (00:37:57): Is that too many?
**Anthony Elliott** (00:37:58): We did have five when a show?
**Anthony Elliott** (00:37:59): show?
**Anthony Elliott** (00:38:00): I you this past time, and we trimmed it down to four, just based on if it felt too cramped on that.
**Anthony Elliott** (00:38:10): It could have just been with the text.
**Anthony Elliott** (00:38:11): I have shorter labels here.
**Anthony Elliott** (00:38:14): So if you're able to keep it to most of these, just have a handful, you know, five letters or so.
**Anthony Elliott** (00:38:20): If you have short labels, we might be able have a fifth one and feel comfortable.
**Anthony Elliott** (00:38:26): But that's something you can play with as well.
**Anthony Elliott** (00:38:28): You don't have to make that decision now.
**Anthony Elliott** (00:38:31): Okay, very good.
**Mike Kaczorowski** (00:38:32): I foresee us changing a couple of those, but yeah, we can take care of that later.
**Anthony Elliott** (00:38:36): What would you offer?
**Mike Kaczorowski** (00:38:39): Well, that's a great place for our donate button, our give button down there, and even the prayer request button.
**Mike Kaczorowski** (00:38:44): Those are the two that I would like to see down there, as opposed to maybe media.
**Mike Kaczorowski** (00:38:48): Yeah, and I'm not sure what Connect does.
**Mike Kaczorowski** (00:38:52): If that gives us the, well, that's kind of like an about page.
**Anthony Elliott** (00:38:57): This has.
**Mike Kaczorowski** (00:39:00): Yeah, there you go.
**Mike Kaczorowski** (00:39:01): Membership form, prayer request.
**Anthony Elliott** (00:39:02): Yeah, that's a good one.
**Mike Kaczorowski** (00:39:03): So maybe just the, we'd like to have the give button down there on the bottom.
**Mike Kaczorowski** (00:39:10): And, but yeah, that's one I would probably like to call out and have it right there.
**Mike Kaczorowski** (00:39:18): I like the connect one, though, because I like where it takes us.
**Mike Kaczorowski** (00:39:21): That's good.
**Anthony Elliott** (00:39:22): Yeah.
**Anthony Elliott** (00:39:23): Home, connect, give.
**Mike Kaczorowski** (00:39:26): Yeah.
**Mike Kaczorowski** (00:39:26): And we can have probably one more.
**Mike Kaczorowski** (00:39:27): If we needed to get rid of one down there, I'd say we can pull the media one out of there and use, you know.
**Anthony Elliott** (00:39:36): That was good.
**Anthony Elliott** (00:39:41): One other feature to show, which I don't think I had working last time, was the search.
**Anthony Elliott** (00:39:46): So you can come in here and type in Bible, whatever you want, and it'll load up that page.
**Anthony Elliott** (00:39:58): Oh, nice.
**Mike Kaczorowski** (00:39:59): Thanks, Bye.
**Anthony Elliott** (00:40:01): So that's pretty, that way on the app, you're not trying to find out where that page is.
**Anthony Elliott** (00:40:06): You can, you can just search for it.
**Anthony Elliott** (00:40:13): Okay.
**Anthony Elliott** (00:40:14): So there are next steps for me is I'll be getting you guys into, try to get you guys the test build so you can see this on your own devices before it goes live in the app stores.
**Anthony Elliott** (00:40:25): And reminder on the, on the timeframe here, I would, I'm, I'm, trying, I'm trying to push this so that we can get you launched because especially the Apple store does have a, at least a week review process.
**Anthony Elliott** (00:40:39): So from when you guys say, yeah, it's good to go, then it's going to take some time before we can actually see it live in the app store.
**Mike Kaczorowski** (00:40:48): All right.
**Mike Kaczorowski** (00:40:50): Real quick on the test process, Anthony, you will need their Apple ID emails, correct?
**Mike Kaczorowski** (00:40:57): The email address is associated with their IO.
**Anthony Elliott** (00:41:01): Yes, yeah, that's correct.
**Anthony Elliott** (00:41:02): Yeah, thank you.
**Mike Kaczorowski** (00:41:03): So, Mike Bell, could you do me a favor and connect at least with Hannah?
**Mike Kaczorowski** (00:41:09): If you could send me the email addresses specifically that are associated with their Apple accounts, that's what they'll need to use.
**Mike Kaczorowski** (00:41:18): And you guys, Steve, Robert, can you put your personal email accounts that you would use to get an app off the store in the chat?
**Mike Kaczorowski** (00:41:30): And then, Steve, if you could also provide for me whatever email address you want to use for the actual backend access of the website, not the app necessarily, not your Apple ID, whatever email address you want to be able to make edits on the app or website, I could use that as well to give you backend access.
**Mike Kaczorowski** (00:41:49): You got it.
**Mike Kaczorowski** (00:41:51): And then as far as what that process is going to look like for you guys, I believe, Anthony, they're going to have to download TestFlight as an app first.
**Mike Kaczorowski** (00:42:00): And then once you're in, it's just an app called TestFlight, and it's pretty straightforward once Anthony sends you the invitation as far as downloading TestFlight is concerned, but as far as the process goes, you're going to download the app called TestFlight that it'll link to just in the email that Anthony sends out.
**Mike Kaczorowski** (00:42:20): And then within the TestFlight app, there's going to be something that references the FFCI app test build, and then you're going to click on that and it's actually going to download that test build, just like a normal app on your phone.
**Mike Kaczorowski** (00:42:34): So just kind of an added step that you need to be aware of, shouldn't be too difficult.
**Mike Kaczorowski** (00:42:41): And then I did have a couple more questions.
**Mike Kaczorowski** (00:42:45): We covered that.
**Mike Kaczorowski** (00:42:48): Mike, I got yours.
**Mike Kaczorowski** (00:42:50): Great.
**Mike Kaczorowski** (00:42:50): Steve got yours.
**Mike Kaczorowski** (00:42:51): Thank you.
**Mike Kaczorowski** (00:42:55): And Steve, that's the email address you want to be able to access the website.
**Mike Kaczorowski** (00:42:58): Is that the same one for Yeah.
**Mike Kaczorowski** (00:43:00): Your Apple ID as well, or are you going to drop a different one?
**Steve Munoz** (00:43:06): It'll be a different one I'm going to type in, right?
**Steve Munoz** (00:43:09): Perfect.
**Steve Munoz** (00:43:10): Thank you.
**Mike Kaczorowski** (00:43:11): And then, yeah, Robert, I'll wait for yours.
**Mike Kaczorowski** (00:43:16): Two quick questions, if I could hijack, just asking about the website real quick, Mike.
**Mike Kaczorowski** (00:43:22): Just two bits of feedback that we wanted a little bit more clarification on.
**Mike Kaczorowski** (00:43:30): You had asked about the app page, and I can go ahead and share screen here.
**Mike Kaczorowski** (00:43:36): It's kind of related to the app.
**Mike Kaczorowski** (00:43:40): We have, let me share here.
**Mike Kaczorowski** (00:43:44): We've just linked directly to the app stores for both of these here.
**Mike Kaczorowski** (00:43:47): And then you had asked about the QR code.
**Mike Kaczorowski** (00:43:49): Right now, this QR code is going to your subsplash page that provides the different links.
**Mike Kaczorowski** (00:43:54): Adam, do you know, did this QR code just come from their previous website?
**Mike Kaczorowski** (00:43:58): Yeah.
**Adam Hardy** (00:44:00): Yeah, we would need to create one with whatever use we want to have for it, so.
**Mike Kaczorowski** (00:44:03): Yeah, so to answer your question, Mike, yeah, basically the QR code is just an image that we put in, and that image knows to be linked to something.
**Mike Kaczorowski** (00:44:10): And so at one point, you guys set up this QR code, and we just downloaded the image from your past site and put it on here.
**Mike Kaczorowski** (00:44:17): So depending on the timing of everything, we might, I don't know, Anthony, like, do we want the app page to be live if we're still pointing people to the Subsplash app when we're so close to launch?
**Mike Kaczorowski** (00:44:30): This app, or how, and I guess, Adam, this might be a strategic question for you, do we want to, like, unpublish this page for now until we're ready to actually release our app, or, you know, I would value you guys' feedback from a strategic standpoint?
**Adam Hardy** (00:44:50): Yeah, I would probably unpublish it until you're ready to launch the app.
**Adam Hardy** (00:44:54): That way you're not sending someone to an old app and then having them re-download when you realize.
**Adam Hardy** (00:44:59): Yeah, I agree.
**Mike Kaczorowski** (00:45:00): Yeah, and that was going to be my next question, and this is where I'm just ignorant, but it's a question that I had, is what is going to happen when we launch our app?
**Mike Kaczorowski** (00:45:07): Is it going to, like, if somebody already has the SubSplash app, is there going to need to be any kind of communication to end users to switch over to this new app or download this new app?
**Mike Kaczorowski** (00:45:18): Or will this one just replace and update the one that they currently have automatically?
**Anthony Elliott** (00:45:25): What we, I'll look into this more, what we would typically do is a transfer request from the old app, from the old publisher to Five Q as the new publisher, and then it would just work.
**Anthony Elliott** (00:45:40): People would get updates.
**Mike Kaczorowski** (00:45:42): Okay.
**Anthony Elliott** (00:45:42): I don't know if SubSplash, you know, I don't know if SubSplash can do that, because that's unique, so I will look into that.
**Mike Kaczorowski** (00:45:55): I'd say whatever we can do to make it as seamless as possible for the end user is what we're
**Adam Hardy** (00:46:00): Yeah, if we can do that, we might look into communicating on the current app that there's going to be a new app that they'll need to download.
**Adam Hardy** (00:46:07): I'm liking to it.
**Mike Kaczorowski** (00:46:09): Yeah, that would be good to know what that step will be, because I'd love to communicate that both on the website and the current app that, you know, hey, that's something we can feature, right?
**Mike Kaczorowski** (00:46:21): New mobile app coming shortly, you know, whatever, and then when it's available, let people know.
**Mike Kaczorowski** (00:46:30): I love the idea of just of it transitioning from one to the other, Anthony, and I don't know, is that something you just look at behind the scenes, or do you make a call?
**Mike Kaczorowski** (00:46:40): Do we make a call to Subsplash directly and say, do you have a process for this, or what do we do?
**Anthony Elliott** (00:46:44): There is an official process in both the app stores that they would have to follow.
**Anthony Elliott** (00:46:49): So, um, that they, Subsplash would have to follow.
**Anthony Elliott** (00:46:52): Yeah, we've, we've done this before with, with other clients and, and they, so you have to talk to a real person and.
**Anthony Elliott** (00:47:00): And when you're working with just one person on their side, but the real person, it is not too bad.
**Anthony Elliott** (00:47:06): But working with a corporation, I don't know how that will go.
**Mike Kaczorowski** (00:47:11): Well, have a call with our Subsplash rep next week to talk about some things along these lines.
**Mike Kaczorowski** (00:47:18): So I'll be sure to ask them about that.
**Anthony Elliott** (00:47:23): Yeah, that would be great.
**Anthony Elliott** (00:47:25): And I can send you some information on that.
**Mike Kaczorowski** (00:47:30): Yeah, they're giving me all sorts of nasty grams right now because we didn't pay our annual subscription.
**Mike Kaczorowski** (00:47:37): He and I had an agreement that we would go month to month, Mike, as we had discussed.
**Mike Kaczorowski** (00:47:41): And for some reason, it's not making it where it needs to make it within their system.
**Mike Kaczorowski** (00:47:47): And so I'm getting a daily reminder that we're all a lot of money.
**Mike Kaczorowski** (00:47:51): But so we have a meeting scheduled for next week to go over that.
**Mike Kaczorowski** (00:47:55): And I'll ask him about this as well.
**Mike Kaczorowski** (00:47:56): And if you need to have a step in and strong arm them a little bit.
**Mike Kaczorowski** (00:48:00): We'd be happy to speak on your behalf.
**Mike Kaczorowski** (00:48:04): So all this to say, yeah, we'll replace the QR code once it comes time, and we have a link to actually download the app.
**Mike Kaczorowski** (00:48:12): And do we want – I heard conflicting things.
**Mike Kaczorowski** (00:48:16): Mike, you would like this page to be live when we launch, but more of a coming soon page?
**Mike Kaczorowski** (00:48:22): Well, yeah.
**Mike Kaczorowski** (00:48:23): I mean, let's find out if there is, in fact, a need.
**Mike Kaczorowski** (00:48:26): You know what I'm saying?
**Mike Kaczorowski** (00:48:26): I I'd like to know what the process is and what the user will experience before we tell them what that's going to look like.
**Mike Kaczorowski** (00:48:34): So we'll get that cleared up.
**Mike Kaczorowski** (00:48:36): Yep.
**Mike Kaczorowski** (00:48:37): And then, you know, we do have that QR code published on some of our materials.
**Mike Kaczorowski** (00:48:44): You know, certainly we can just, you know, eventually replace it, but is there any way to reuse the QR code to link to the new app?
**Mike Kaczorowski** (00:48:54): Or if that transition happens behind the scenes, would that QR code still work?
**Mike Kaczorowski** (00:48:59): let's right.
**Anthony Elliott** (00:49:00): That's one of my main drivers for that is...
**Anthony Elliott** (00:49:03): Depends on where that, yeah, that goes.
**Anthony Elliott** (00:49:05): If it's a domain-specific URL, we can redirect it.
**Mike Kaczorowski** (00:49:10): Yeah, when you click on it now, it just says Subsplash.
**Mike Kaczorowski** (00:49:13): think it's a Subsplash domain.
**Mike Kaczorowski** (00:49:16): Yeah.
**Mike Kaczorowski** (00:49:17): Yeah, let's see here.
**Adam Hardy** (00:49:19): That becomes a little problematic.
**Adam Hardy** (00:49:21): Yeah, Subsplash.com.
**Adam Hardy** (00:49:24): So we don't have control of that.
**Mike Kaczorowski** (00:49:26): Well, that's, again, I'll chat with that guy, and that's okay if we have to.
**Mike Kaczorowski** (00:49:29): I left it off our new Bibles because I knew this was coming.
**Mike Kaczorowski** (00:49:33): That was my big...
**Mike Kaczorowski** (00:49:34): Most of the other stuff that we have it on is, you know, stuff we'll eventually run out of, and we'll just be able to put a new QR code on it, you know, if and when that time comes.
**Mike Kaczorowski** (00:49:45): Mike, real quick, one piece of feedback that dropped in Pastel was that the membership link was not connecting.
**Mike Kaczorowski** (00:49:51): I'm assuming if Thunder get involved...
**Mike Kaczorowski** (00:49:55): Yeah.
**Mike Kaczorowski** (00:49:55): We were a little bit lost because...
**Mike Kaczorowski** (00:49:57): Was it the Become a Member link?
**Mike Kaczorowski** (00:49:59): ...
**Mike Kaczorowski** (00:50:00): Is that what you were referring to, or was it something on this page specifically?
**Mike Kaczorowski** (00:50:03): It was the member, well, no, it's the membership form, I think.
**Mike Kaczorowski** (00:50:07): Right here.
**Mike Kaczorowski** (00:50:09): And maybe it is.
**Mike Kaczorowski** (00:50:10): It is slow, but it is coming up, and it's attached to Church Suite, so it's the form.
**Mike Kaczorowski** (00:50:16): So it does look like it's working.
**Mike Kaczorowski** (00:50:18): I just wanted to make sure I knew exactly what you were looking at there.
**Mike Kaczorowski** (00:50:23): And I know that there was some hang-up, you know, because you were dropping some feedback in the Philippines.
**Mike Kaczorowski** (00:50:29): Yeah.
**Mike Kaczorowski** (00:50:29): It was slower, so it might have been it.
**Mike Kaczorowski** (00:50:31): So I'll resolve that comment then.
**Mike Kaczorowski** (00:50:33): And then we do have a couple tasks set up for Adam regarding the additional language, and then there were some footer updates as well.
**Mike Kaczorowski** (00:50:40): So we should be able to get those to you soon.
**Mike Kaczorowski** (00:50:42): And then the store, Nathan is actually setting up the subdomain for the – it might be done already.
**Mike Kaczorowski** (00:50:48): I'm going to check.
**Mike Kaczorowski** (00:50:50): He is in the process today or tomorrow setting up connecting you to the store.
**Mike Kaczorowski** (00:50:54): So it's not done yet.
**Mike Kaczorowski** (00:50:55): Yeah.
**Mike Kaczorowski** (00:50:55): But the store is set up and ready for you to review.
**Mike Kaczorowski** (00:50:58): We want to make sure you've got an eye on it.
**Mike Kaczorowski** (00:50:59): We
**Mike Kaczorowski** (00:51:02): But Nathan's just got to set up that subdomain and get it connected.
**Mike Kaczorowski** (00:51:06): So we should be good here soon and I'll let you know as soon as it's live.
**Mike Kaczorowski** (00:51:10): That way you can get an eye on it.
**Mike Kaczorowski** (00:51:12): And then just a reminder, we are meeting next week to talk about just more additional training that you were hoping for.
**Mike Kaczorowski** (00:51:19): And then I'm going to bring Nathan on that call as well just to train you on Shopify.
**Mike Kaczorowski** (00:51:22): It makes you feel comfortable with Shopify and the storefront as well.
**Mike Kaczorowski** (00:51:27): Yeah, just FYI, when I was in the Philippines, to stay on that page real quick, when I was in the Philippines, where it says select a language up there, it had a, it was almost like it added the Tagalog, you know, Filipino as an option up there.
**Mike Kaczorowski** (00:51:48): Interesting.
**Mike Kaczorowski** (00:51:48): Yeah, and it didn't put it in the drop down, it kind of, it kind of stuffed it in next to where the, where the, you know, where the drop down is on the, on the.
**Mike Kaczorowski** (00:51:59): I'm to bit.
**Mike Kaczorowski** (00:52:00): The header up there, it just put it up there.
**Mike Kaczorowski** (00:52:03): I never, I didn't click on it to see if it actually would go to that language, but it was automatically, because I was in the Philippines, was suggesting that language as an option, just so you know.
**Adam Hardy** (00:52:17): I'm it's part of the Google Translation service.
**Adam Hardy** (00:52:20): probably picks up where you're located, yeah.
**Adam Hardy** (00:52:22): Yeah, that's neat.
**Mike Kaczorowski** (00:52:23): That's very cool.
**Mike Kaczorowski** (00:52:24): Well, we'll, you know, we do have some, you know, I got a German guy, you know, I had him look at it briefly, because he was with us on that trip, and he was excited to see that.
**Mike Kaczorowski** (00:52:38): But all that to say, I wonder what that'll look like in other countries.
**Mike Kaczorowski** (00:52:41): We, you know, we do have people in Africa and other places, if they go to the website, if that'll be something that just automatically loads in there for them.
**Mike Kaczorowski** (00:52:49): Yeah, that'd be very nice.
**Robert Blair** (00:52:52): Just on that, on the language choice, whenever you click on one of those languages, you choose any of them.
**Robert Blair** (00:53:01): Does it automatically then bring English back into that list, if you were to go back?
**Adam Hardy** (00:53:06): It gives you a second bar at the top, so you can go back to the original, yeah.
**Adam Hardy** (00:53:11): It gives you kind of the Google Translate bar, yeah.
**Robert Blair** (00:53:13): Okay.
**Mike Kaczorowski** (00:53:16): Yeah, I was in Translation, you know, Hades there for a minute when I first saw this, and I didn't see that bar at the top, so I couldn't get out of Spanish.
**Adam Hardy** (00:53:28): But then Adam showed me how that works, and so, yeah.
**Adam Hardy** (00:53:31): well, there was an issue at first, when we had an infinite loop, you couldn't get out once you got in.
**Mike Kaczorowski** (00:53:35): Yeah, that's probably, I was stuck in that for a minute, but anyway, that works, that works good.
**Mike Kaczorowski** (00:53:41): Did you see that, Robert?
**Mike Kaczorowski** (00:53:42): Did it work okay for you?
**Mike Kaczorowski** (00:53:45): Perfect.
**Mike Kaczorowski** (00:53:46): All right.
**Mike Kaczorowski** (00:53:48): I think I'm all set.
**Mike Kaczorowski** (00:53:49): Mike, I mean, we do still have eight minutes left of our own scheduled time.
**Mike Kaczorowski** (00:53:53): And was there anything that Adam can show you real quick right now that you're interested in, as far as the training is concerned, a quick hit that would help you out?
**Mike Kaczorowski** (00:53:59): Yeah.
**Mike Kaczorowski** (00:54:00): If you don't mind, we've got a few minutes.
**Mike Kaczorowski** (00:54:01): If you go back to the back end, mean, that one little trick you talked about, and, you know, I don't know, is it Sydney is kind of working on this?
**Mike Kaczorowski** (00:54:10): Yeah, Sydney's been working just through your feedback and whatever she can fix, she's been able to fix, and there's some things that...
**Mike Kaczorowski** (00:54:17): Yeah, she gave me, I asked about, there was a picture I added, and, you know, under one of the banners, if you go to President's...
**Mike Kaczorowski** (00:54:24): President's letter, yep.
**Mike Kaczorowski** (00:54:25): Yep, President's letter, if you make your way there.
**Mike Kaczorowski** (00:54:30): Originally, Adam, for context, Mike added it in, and it was just cutting off the heads on the image.
**Mike Kaczorowski** (00:54:37): Sydney has fixed it, but, yeah, I have to show Mike how to get it, it doesn't do that.
**Adam Hardy** (00:54:43): Yeah, so if go into the background image, you can do a crop, and then you can move specifically where you want it to crop, and when you get those head cutoffs, if you have the room above, it's best to kind of give yourself some room above their heads when you crop.
**Mike Kaczorowski** (00:54:57): Yeah.
**Adam Hardy** (00:54:58): That moves them more to the center.
**Mike Kaczorowski** (00:55:00): Is there a, okay, I see that.
**Mike Kaczorowski** (00:55:04): Now go to the, it's on the resources page.
**Mike Kaczorowski** (00:55:09): It's for the, it actually is for the media ministry on the resources page.
**Mike Kaczorowski** (00:55:14): I put, I created, I did, I did an AI image first time ever.
**Mike Kaczorowski** (00:55:21): Nice.
**Mike Kaczorowski** (00:55:21): And if you go down, oh gosh, is it there?
**Mike Kaczorowski** (00:55:27): No, dang it, where was it?
**Adam Hardy** (00:55:32): Yeah, see where it says FFC mobile app right there?
**Mike Kaczorowski** (00:55:35): I changed that picture.
**Mike Kaczorowski** (00:55:38): If you go down where it says back on the other page, on that resource page.
**Mike Kaczorowski** (00:55:48): I changed that picture.
**Mike Kaczorowski** (00:55:51): Um, what happened?
**Mike Kaczorowski** (00:55:53): How come you're not seeing it?
**Adam Hardy** (00:55:58): Oh, sorry.
**Adam Hardy** (00:56:00): Do you know what you named it?
**Mike Kaczorowski** (00:56:04): I'm going to look on the homepage.
**Mike Kaczorowski** (00:56:08): It's on the homepage.
**Mike Kaczorowski** (00:56:10): I'm sorry.
**Mike Kaczorowski** (00:56:10): Go to the homepage.
**Mike Kaczorowski** (00:56:11): Yeah, Media Ministry, right?
**Mike Kaczorowski** (00:56:13): Yeah, go to the homepage.
**Mike Kaczorowski** (00:56:14): So I probably need to update it on that resource page also.
**Mike Kaczorowski** (00:56:17): But if you go to the homepage.
**Mike Kaczorowski** (00:56:18): And that's a pretty good looking AI generated image, Mike.
**Mike Kaczorowski** (00:56:22): did a good job.
**Mike Kaczorowski** (00:56:23): Dude, all I did was write firefighter listening to a podcast.
**Adam Hardy** (00:56:28): That's awesome.
**Adam Hardy** (00:56:29): And that generated out of Gemini.
**Mike Kaczorowski** (00:56:32): And it was like, okay, I'm using it.
**Mike Kaczorowski** (00:56:34): But I think that's one thing I wanted to point out.
**Mike Kaczorowski** (00:56:36): But the other thing is, I had to crop that one to make it work.
**Mike Kaczorowski** (00:56:41): And I used a, there were some presets in there as far as cropping.
**Adam Hardy** (00:56:46): Is that?
**Adam Hardy** (00:56:47): Yes, the state of those presets.
**Adam Hardy** (00:56:49): What that does is it makes sure that all the images are the same height and width.
**Adam Hardy** (00:56:55): So if we set to that pre-crop ratio of three to two, then they're all going to...-bye.
**Adam Hardy** (00:56:59): Thank
**Adam Hardy** (00:57:00): I'm going to look the same rather than having one that's taller or one that's wider.
**Mike Kaczorowski** (00:57:04): Yeah, that's what I did.
**Mike Kaczorowski** (00:57:05): And what I noticed, too, is that it retains the full size of the picture in the back end piece.
**Adam Hardy** (00:57:11): just shows you where the crop is.
**Adam Hardy** (00:57:13): Yep.
**Mike Kaczorowski** (00:57:14): And then it shows up as you expect it to on the page you're working with.
**Adam Hardy** (00:57:21): Yeah, what that does, it gives you a little flexibility so you don't have to edit a photo before you bring it in.
**Adam Hardy** (00:57:26): You can bring it in and then crop it down, which is nice.
**Adam Hardy** (00:57:29): Yeah.
**Mike Kaczorowski** (00:57:30): Yeah, I was pretty, you know, we're all scared of AI and everything.
**Mike Kaczorowski** (00:57:33): I get it.
**Mike Kaczorowski** (00:57:34): But, man, it does some cool stuff.
**Mike Kaczorowski** (00:57:36): That was one of those cool things.
**Mike Kaczorowski** (00:57:38): You can use it for good instead of evil.
**Mike Kaczorowski** (00:57:40): It'll get you a long way.
**Mike Kaczorowski** (00:57:42): Yeah.
**Adam Hardy** (00:57:43): And that picture, it's, yeah, top notch.
**Adam Hardy** (00:57:46): Yeah.
**Mike Kaczorowski** (00:57:47): Make sure you count his fingers, though.
**Mike Kaczorowski** (00:57:49): For some reason, image generation through AI struggles with hands and fingers.
**Adam Hardy** (00:57:54): We got the right amount.
**Adam Hardy** (00:57:55): He does.
**Adam Hardy** (00:57:55): He's got six fingers.
**Mike Kaczorowski** (00:57:57): Has he?
**Mike Kaczorowski** (00:57:58): Yeah, he does.
**Mike Kaczorowski** (00:57:59): One.
**Mike Kaczorowski** (00:57:59): One.
**Adam Hardy** (00:58:00): Two, three, four, five to me.
**Adam Hardy** (00:58:03): Okay, because he's got a thumb.
**Mike Kaczorowski** (00:58:04): Oh, yeah.
**Mike Kaczorowski** (00:58:05): Okay, yeah, you're right.
**Mike Kaczorowski** (00:58:05): He's got five.
**Mike Kaczorowski** (00:58:06): He's good.
**Mike Kaczorowski** (00:58:07): He's got five.
**Mike Kaczorowski** (00:58:08): For whatever reason, I can't seem to figure out fingers and hand.
**Mike Kaczorowski** (00:58:13): Yeah, I was looking for, like, the third arm and stuff like that there.
**Adam Hardy** (00:58:17): The only thing that I think looks a little weird is he has headphones on over his helmet.
**Mike Kaczorowski** (00:58:22): Look at the dog.
**Mike Kaczorowski** (00:58:23): Is it a double-headed dog?
**Mike Kaczorowski** (00:58:25): I wondered about the two-headed dog or if that was a foot coming out, but it might be a double-headed dog.
**Mike Kaczorowski** (00:58:30): a weird leg.
**Mike Kaczorowski** (00:58:32): It could pass as a weird leg, yeah.
**Mike Kaczorowski** (00:58:35): I think we should keep the two-headed dog in there, Robert.
**Mike Kaczorowski** (00:58:38): Give it a name.
**Mike Kaczorowski** (00:58:39): See if anybody figures it out.
**Mike Kaczorowski** (00:58:42): I love it.
**Mike Kaczorowski** (00:58:44): Yeah, it's awesome.
**Mike Kaczorowski** (00:58:45): No, that's the kind of stuff.
**Mike Kaczorowski** (00:58:46): I mean, you know, if you just go to the back end, any page in the back end there, Nate, I mean, Adam, and not that we get it, but there's a few things in there, like life...
**Mike Kaczorowski** (00:59:00): I that page where you have a lot of options to set, like, horizontal, vertical height.
**Mike Kaczorowski** (00:59:08): You know, I just don't know if those are things that we really are going to use and if they'd be helpful.
**Mike Kaczorowski** (00:59:14): You know, I don't want to play around with stuff that we're not really going to use, you know.
**Adam Hardy** (00:59:18): In regards to when you're editing an image?
**Mike Kaczorowski** (00:59:21): Yeah, see right there?
**Mike Kaczorowski** (00:59:23): See, it gives you max width, align image, margin bottom, margin top, you know, all that stuff there.
**Adam Hardy** (00:59:29): Yeah, that would come into play when you're just trying, you don't want an image to span the whole width.
**Adam Hardy** (00:59:34): Maybe, for whatever reason, you have an image next to a text in a two-column layout and you kind of want a smaller image.
**Adam Hardy** (00:59:40): Then you might set, like, a max width so it's smaller.
**Adam Hardy** (00:59:43): And then you might want it to be centered in that column.
**Adam Hardy** (00:59:47): Then you would come over here and you'd hit center, if that makes sense.
**Mike Kaczorowski** (00:59:50): Okay, that's within a column that's kind of, you know, if you, most everything by default is one column, right, unless you make it.
**Mike Kaczorowski** (00:59:56): Yeah, by default, these are all these images are going to span.
**Adam Hardy** (01:00:00): The width of the column.
**Adam Hardy** (01:00:01): So they're going to be as large as possible in that column.
**Adam Hardy** (01:00:04): But if you're like, that's just too big, you know, I want a smaller image.
**Adam Hardy** (01:00:07): I could come in here and I could set, say, I want this, we're just going to change this for a second to 250.
**Adam Hardy** (01:00:13): You can see.
**Adam Hardy** (01:00:14): And then I want it centered, you know, right above that heading.
**Adam Hardy** (01:00:17): If I come in here, we'll just change this so you can see.
**Mike Kaczorowski** (01:00:19): Okay.
**Mike Kaczorowski** (01:00:20): I come back.
**Adam Hardy** (01:00:23): And now I have a smaller image.
**Adam Hardy** (01:00:25): Maybe I like, you know, that look.
**Adam Hardy** (01:00:26): like a little smaller image ahead of the, ahead of the.
**Mike Kaczorowski** (01:00:30): Gives you just more options.
**Adam Hardy** (01:00:32): Okay.
**Mike Kaczorowski** (01:00:32): And then if you go to the, you don't have to go there, but there's a, somewhere, you know, on our ERT or one of our training mission sites, it shows a bunch of pictures from a previous trip.
**Mike Kaczorowski** (01:00:47): And it, you know, I, I got rid of a lot of the pictures.
**Mike Kaczorowski** (01:00:52): You go to mission trips there.
**Mike Kaczorowski** (01:00:56): Okay.
**Mike Kaczorowski** (01:00:57): Okay.
**Mike Kaczorowski** (01:00:58): Okay.
**Mike Kaczorowski** (01:00:58): Okay.
**Mike Kaczorowski** (01:00:58): It's, uh,
**Mike Kaczorowski** (01:01:01): Yeah, you see these pictures here?
**Mike Kaczorowski** (01:01:05): Now that's four, that's the way I'm looking at that, trying to understand, is that where the three pictures are below the one?
**Mike Kaczorowski** (01:01:14): Is that three columns?
**Adam Hardy** (01:01:16): No, so that's four, you have a four, so you could go, hey, I want this to only be a three column.
**Adam Hardy** (01:01:20): It's going to change the size, so you're going to have bigger images, but then you could do something like this, get rid of.
**Adam Hardy** (01:01:27): But if you didn't have a picture there, it's just not going to show anything, right?
**Adam Hardy** (01:01:31): Right, so if I did that, come back in, you're going to have bigger images, but now you're going to have three instead of four, right?
**Adam Hardy** (01:01:41): Okay, all right.
**Mike Kaczorowski** (01:01:42): I saw that there was a page that had like four rows of pictures, and I took a few out, and it looked like a checkerboard after that.
**Adam Hardy** (01:01:51): Yeah, you'll either replace the image that's missing in the thing, or you can reduce the amount of columns you have.
**Adam Hardy** (01:01:57): You have a couple of options.
**Mike Kaczorowski** (01:01:58): Okay.
**Adam Hardy** (01:01:59): Okay.
**Mike Kaczorowski** (01:02:00): And you can even drag.
**Adam Hardy** (01:02:02): So say you accidentally created, I don't know, we're just going to duplicate this for training purposes here, and you have whatever.
**Adam Hardy** (01:02:11): You have an open spot here.
**Adam Hardy** (01:02:13): You can drag, you know, you can drag your pictures till it makes sense, right?
**Adam Hardy** (01:02:19): And then you're back to the normal way it should be.
**Adam Hardy** (01:02:22): Yeah.
**Mike Kaczorowski** (01:02:24): We did have a comment about the 911 button, Mike, or the 911, or the 988 number.
**Mike Kaczorowski** (01:02:32): There was something there was, it was located on a page that was kind of deep into the page.
**Mike Kaczorowski** (01:02:37): It was one of those things that we had considered.
**Mike Kaczorowski** (01:02:43): Right there, right there.
**Mike Kaczorowski** (01:02:46): Kind of far down on it.
**Mike Kaczorowski** (01:02:47): Robert, this is a question for you as well, if you're still there.
**Mike Kaczorowski** (01:02:51): Did he drop off?
**Mike Kaczorowski** (01:02:53): Yeah.
**Steve Munoz** (01:02:55): Yeah.
**Mike Kaczorowski** (01:02:56): I'm going to ask for feedback from our group.
**Mike Kaczorowski** (01:03:00): That's not necessarily a Christian site, but we do reference it as a resource, and I need to talk to folks to see how prominent they want to make that as an option.
**Mike Kaczorowski** (01:03:13): We had talked about having it up there in that red box, that red line at some point, but that's more of an internal question than anything, I think.
**Mike Kaczorowski** (01:03:21): We could add it up there, and then it'd say something like, probably like, get help now, and then have their logo or whatever next to it.
**Mike Kaczorowski** (01:03:31): Yeah.
**Mike Kaczorowski** (01:03:32): Last thing, one second I got left, if you go to events, go to the event page or section.
**Mike Kaczorowski** (01:03:40): Yeah, I see.
**Mike Kaczorowski** (01:03:41): Now, if I want, like, we just got back from the Philippines, so one of the thoughts would be, it says upcoming events, but it could also be, you know, a recap of what we just did, right, here?
**Mike Kaczorowski** (01:03:53): I mean, we could put a video or something in one of those columns and link to that.
**Mike Kaczorowski** (01:03:57): flexible, yeah, you could.
**Adam Hardy** (01:03:58): Yeah.
**Adam Hardy** (01:04:00): You could put, like, Past Event Recap, or I just need to title it correctly.
**Adam Hardy** (01:04:04): There's a lot of flexibility with that page, so I can come in here.
**Adam Hardy** (01:04:08): Let's get involved.
**Adam Hardy** (01:04:10): Events.
**Adam Hardy** (01:04:12): You can add another column, so you could go bigger, or you could just change out one column, change the titles.
**Mike Kaczorowski** (01:04:20): Now back to what you're looking at right there, I can see two columns.
**Mike Kaczorowski** (01:04:24): Now, the two pictures below, there's four pictures there.
**Adam Hardy** (01:04:27): Is that?
**Adam Hardy** (01:04:28): This one's hiding, so we can just get rid of this.
**Adam Hardy** (01:04:30): think we just were testing whether an image or a video would look better there.
**Mike Kaczorowski** (01:04:34): No, what I'm asking though, okay, I think I know what you're doing there.
**Mike Kaczorowski** (01:04:38): All right, we're good.
**Mike Kaczorowski** (01:04:41): Yeah, yeah, what we may do is just use, you know, maybe move, slide, we'll slide the upcoming event to the left and put, like, a recap on the right of something.
**Mike Kaczorowski** (01:04:50): needed three, you can change the columns.
**Adam Hardy** (01:04:53): could have, I'm to add a third one here, and then you'd have a third column.
**Mike Kaczorowski** (01:04:58): Is there a way to put something below that?
**Mike Kaczorowski** (01:05:00): Is a, you know, maybe below that, you put recaps below the coming events?
**Mike Kaczorowski** (01:05:05): Is that a new block?
**Adam Hardy** (01:05:06): Insert after, and you could have, you could have two, you could have a single column, just whatever you want to do, and then you'd put in your heading, you could even copy the heading from here and use the same styling.
**Adam Hardy** (01:05:19): Okay.
**Steve Munoz** (01:05:20): Hey, Mike, would you, I mean, just for the sake of like, not having it so many places, I mean, maybe you could, for the recap, we talked about the feature item, that's the Top of Minds, that's something recent, we could just put in that featured item, and then leave this to be just events.
**Steve Munoz** (01:05:36): But, you know, somewhere where they can easily access it, and they can see what, you know, what you guys did while you were on that mission trip.
**Mike Kaczorowski** (01:05:43): Yeah, for the mobile app, absolutely, I can see where we would pull that specific thing out as a featured item.
**Mike Kaczorowski** (01:05:50): And have it there for the website.
**Mike Kaczorowski** (01:05:54): You know, yeah, I'm not sure if we'd have a separate spot to see something like that, or if we just include it.
**Mike Kaczorowski** (01:06:00): On the events page.
**Mike Kaczorowski** (01:06:02): We'll have to play with that.
**Adam Hardy** (01:06:05): Yeah, you could add another section, you can add it down here.
**Adam Hardy** (01:06:09): You can have recap.
**Adam Hardy** (01:06:13): Let's create another column.
**Mike Kaczorowski** (01:06:15): Yeah.
**Mike Kaczorowski** (01:06:18): Yeah, we'll play with that, Steve.
**Mike Kaczorowski** (01:06:20): You know, so it works the way we want it to in both places.
**Anthony Elliott** (01:06:31): Mike Bell, did do some research just now on the transfer of mobile apps as well, and it is possible for SubSplash to do.
**Anthony Elliott** (01:06:41): I'll send you the information.
**Anthony Elliott** (01:06:44): It's highly unlikely SubSplash would do it, in my opinion, because they would have to initiate it and send it to us.
**Anthony Elliott** (01:06:51): If they did, you'd be able to keep your existing number of installs and existing reviews and those people who...
**Anthony Elliott** (01:07:00): If the app, it would still work like it would just update to the newest version.
**Anthony Elliott** (01:07:04): So that would be the cleanest.
**Anthony Elliott** (01:07:06): But we do have to go through a process with SubSplash on that.
**Anthony Elliott** (01:07:12): Okay, they've been good to work with.
**Mike Kaczorowski** (01:07:14): They haven't been giving me any hassles really about this.
**Mike Kaczorowski** (01:07:17): So let's give that a shot.
**Mike Kaczorowski** (01:07:19): If you've got some info, that'd be good if I can act like I know what I'm talking about when I have it next week, you know.
**Mike Kaczorowski** (01:07:26): Great.
**Anthony Elliott** (01:07:26): And if they say no, if they can't do it, then...
**Anthony Elliott** (01:07:30): We'll just launch a new app and they'll turn off the old app when you start paying.
**Anthony Elliott** (01:07:35): Yeah.
**Mike Kaczorowski** (01:07:38): Okay.
**Mike Kaczorowski** (01:07:39): Sounds good.
**Mike Kaczorowski** (01:07:40): Steve, that's been helpful.
**Mike Kaczorowski** (01:07:42): I mean, just to kind of, know it's a brand, it's a, it's a, you know, first look, but hopefully once you get the testimony on your phone, we can kind of get into more.
**Mike Kaczorowski** (01:07:50): Like, you know, we're going to learn, you and I, and whoever will learn how to make it work on the back end.
**Mike Kaczorowski** (01:07:56): I think it's going to be a good experience overall.
**Adam Hardy** (01:08:00): Another thing that you guys will have is Journity, too, at your disposal once you get training for that.
**Adam Hardy** (01:08:05): So things like past recap on event, you could serve as a pop-up as a Journity waypoint, and people could click there to read more about how the past event went.
**Adam Hardy** (01:08:15): And then you can also target mobile people viewing on a mobile device.
**Adam Hardy** (01:08:19): You could say, hey, we have a mobile app, did you know?
**Adam Hardy** (01:08:21): Go download it from the App Store.
**Adam Hardy** (01:08:24): So those are some things that you can do once we have Journity running.
**Adam Hardy** (01:08:30): Very cool.
**Mike Kaczorowski** (01:08:31): Yeah, and just a reminder, we're going to be around.
**Mike Kaczorowski** (01:08:33): We're not going anywhere.
**Mike Kaczorowski** (01:08:34): We're happy to answer any kind of questions that you might have and not going anywhere.
**Mike Kaczorowski** (01:08:38): Steve, I'm setting you up as a back-end user right now.
**Mike Kaczorowski** (01:08:41): I'll actually just email you instructions on how I get into the back-end, and then once you're in, feel free to reach out if you have other questions, all right?
**Mike Kaczorowski** (01:08:49): Hey, stand by just one second.
**Mike Kaczorowski** (01:08:52): If you don't mind, Mike, I'm going to drop in an email from Hannah.
**Mike Kaczorowski** (01:08:56): Yeah, and if it works, If not, I'm sure.
**Mike Kaczorowski** (01:09:00): So we'll find out.
**Mike Kaczorowski** (01:09:02): This is for the Apple ID?
**Mike Kaczorowski** (01:09:04): Yeah.
**Mike Kaczorowski** (01:09:05): Okay.
**Mike Kaczorowski** (01:09:09): And I did just send her a message, so we'll see.
**Mike Kaczorowski** (01:09:11): Oh, you did?
**Mike Kaczorowski** (01:09:12): Yeah, I just sent it.
**Mike Kaczorowski** (01:09:14): I actually copied Elon as well.
**Mike Kaczorowski** (01:09:16): So if you want to wait for her to respond, that would be fine, too.
**Mike Kaczorowski** (01:09:21): Okay.
**Mike Kaczorowski** (01:09:22): I'm going to put it in there, and if it's different, we'll let you know.
**Mike Kaczorowski** (01:09:26): Okay.
**Mike Kaczorowski** (01:09:26): Sounds good.
**Mike Kaczorowski** (01:09:29): This is the one I have for her that's not a FFC.
**Mike Kaczorowski** (01:09:36): Perfect.
**Mike Kaczorowski** (01:09:38): All right.
**Mike Kaczorowski** (01:09:38): Is there anything else?
**Mike Kaczorowski** (01:09:41): There always is, but I want to respect your time.
**Mike Kaczorowski** (01:09:45): Always.
**Mike Kaczorowski** (01:09:45): The weekend's upon us.
**Mike Kaczorowski** (01:09:46): We're almost there.
**Mike Kaczorowski** (01:09:48): Yeah.
**Mike Kaczorowski** (01:09:48): Appreciate your guys' time.
**Mike Kaczorowski** (01:09:49): Mike, we'll see you next week, all right?
**Mike Kaczorowski** (01:09:51): Yes, sir.
**Mike Kaczorowski** (01:09:52): See you guys.
**Mike Kaczorowski** (01:09:53): See you guys.
**Mike Kaczorowski** (01:09:54): Thank you, Steve.
**Mike Kaczorowski** (01:09:54): See you, buddy.
**Mike Kaczorowski** (01:09:55): Bye.
**Mike Kaczorowski** (01:09:56): Bye.

---

## Action Items

[ ] **Fix Featured/Resources carousel scroll to end** - Anthony Elliott (00:09:27)
[ ] **Investigate noindex for app-only pages; implement if feasible** - Anthony Elliott (00:13:04)
[ ] **Update Media tab to show categories; add 'Files of the Month' category** - Anthony Elliott (00:16:41)
[ ] **Add ChurchSuite integration to parking lot for future consideration** - Mike Kaczorowski (00:32:49)
[ ] **Create mobile-optimized Prayer Request page in Mobile folder; link app Prayer Request to it** - Mike Kaczorowski (00:33:49)
[ ] **Add Give button to app bottom nav; remove Media** - Anthony Elliott (00:38:28)
[ ] **Collect Apple IDs from Hannah/Elon; send to Anthony** - None (00:40:52)
[ ] **Collect Apple IDs from Steve/Robert; send to Anthony** - Mike Kaczorowski (00:41:07)
[ ] **Collect Android tester email; send to Anthony** - Mike Kaczorowski (00:41:07)
[ ] **Create Steve’s backend user; email login instructions** - Mike Kaczorowski (00:41:19)
[ ] **Unpublish current App page until new app launches** - Mike Kaczorowski (00:44:39)
[ ] **Send app transfer process info to Mike K.** - Anthony Elliott (00:47:12)
[ ] **Resolve Pastel comment re: membership link** - Mike Kaczorowski (00:49:34)
[ ] **Confirm Shopify store subdomain live; notify Mike K.** - None (00:50:31)
[ ] **Decide 911/988 prominence; implement placement** - Mike Kaczorowski (01:02:13)
[ ] **Decide Events recap placement (Featured vs Events page); implement** - Mike Kaczorowski (01:03:29)
