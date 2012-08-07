---
tags: ['Promoted']
layout: post
title: Arbitrary Breakpoints vs. Robots
---

{% excerpt %}
No matter how hard I try, I will never consider myself to be a good designer. Rather, I consider myself to have a working knowledge of best UX practices, and as much as I love and appreciate the principles of UX design &mdash; especially responsive concerns such as content choreography &mdash; I'm just no good when it comes to piecing together a design. All that said, I wanted my blog to be a place where I would feel comfortable with my writing. The fundamental criterion of this design was to hold together various types of content in one place: personal writing, my work and my photography.

The reading experience of people who come here is incredibly important to me, as a typography lover myself. I don't trust myself to make those designs, and fortunately I was able to rest on the shoulders of giants &mdash; or should I say, maths &mdash; to achieve a reading experience I would consider optimal. Call me crazy.

## Golden Ratio Typography

Ever since I read about a theory that uses [the golden ratio to calculate optimal typography](http://www.pearsonified.com/2011/12/golden-ratio-typography.php), my appreciation of print design has been taken to a whole new level. In all of my previous projects I had either defined a relative line height (read: 1.5) for my typography or applied my [typography to a baseline to maintain a vertical rhythm](http://www.alistapart.com/articles/settingtypeontheweb/). Seeing all of my columns line up perfectly was damn pleasing for the nerd inside of me. However, two columns of text, each with different font sizes but equal in line-height; this probably isn't going to provide the user with an optimal reading experience.
{% endexcerpt %}

In print media, the line height is determined by the content width. Take a narrow column of text; the eye doesn't have to travel so far at the end of a line to get to the start of the new line. It is for this reason I believe the line height of text should be determined by the width of the column. You would think that setting relative line heights and then increasing the font size for wider screens would be enough, but if the content width of your column stays the same, then your line height is most likely going to need to be changed as well - if you care about your users reading experience. Relative line heights are easy, and truthfully doing it this way is a pain (especially on responsive builds), but it's definitely something worth considering.

With all relative font sizes now gone, I chose to let the type design itself. The Golden Ratio Typography theory calculates optimal settings however you want it to. If you have a design constraint of say, a device that is 320px wide, but you want your font size to be no less than 16px, then you can calculate the optimal line height based on this content width and font size. After I designed for mobile, almost all of those constraints had disappeared. I defined an array of font sizes, and out come the optimal content width and line height. This was essentially all I needed for my design.

## Doing the Math

Fortunately, there is a [calculator online](http://www.pearsonified.com/typography/) for you to run through some tests and have a go for yourself. However, being a devotee of CSS preprocessors, I chose to leave these calculations until run time for maintainability reasons.

    // settings

    $type-set: 16px 320px, 16px 480px, 16px, 18px, 20px;

This two dimension list provides me with two options: font size and breakpoint. My first breakpoint is 320px, for which I chose to serve a font size of 16px. This is followed by a breakpoint of 480px with a font size of 16px once again. Finally, I have three font sizes: 16px, 18px and 20px, all of which have no width restrictions.

    // library/type-set

    @mixin type-set($set: $type-set) {

      @each $step in $set {
        // Variables hoisted to the top
        $font-size: nth($step, 1);
        $line-height: 0;
        $content-width: 0;
        $unit: golden-unit($font-size);

        $breakpoint: 0;
        $index: index($set, $step) - 1;

        @if (length($step) >= 2) {
          // If a constraint has been applied, we just need to calculate the
          // optimal line height.
          $content-width: nth($step, 2);

          $line-height: golden-height-adjusted($content-width, $font-size);

        } @else if ($breakpoint == 0) {
          // If a constraint hasn't been applied, we are free to generate a content
          // width and line height based on the optimal settings

          $line-height: golden-height($font-size);
          $content-width: golden-width-adjusted($font-size, $line-height);

        }

        // Finally, created a media query and generate the styles of the type system.
        @include breakpoint($content-width) {
          @include type-system($font-size, $line-height, $content-width, $index);
        }
      }

    }

When called, this mixin will loop through my `$type-set` list and run the golden ratio calculations through the [Golden Ratio Typography plugin for Compass](https://github.com/maxbeatty/goldentype). For list items with a breakpoint, the optimal line height is calculated, whereas for those without breakpoints, optimal line height and content width is calculated. On each iteration, a media query is defined - the breakpoint for which is calculated based on the optimal content width. Inside of this media query I make a call to another mixin called `type-system`.

    // foundations/type-system

    @mixin type-system($font-size, $line-height, $content-width, $index) {
      body {
        font-size: $font-size;
        line-height: $line-height;
      }

      p,
      ul,
      ol {
        margin: {
          top: $line-height;
          bottom: $line-height;
        };
      }

      .container,
      .post-content {
        max-width: $content-width;
      }
    }

When called, this mixin receives the results of our previous calculations in the form of `$font-size`, `$line-height`, `$content-width` and `$container-width`. Last but not least, I can use these values in my CSS.

    // base

    @import "settings";

    @import "library/type-set";

    @import "foundations/type-system";

    @include type-set();

Finally, I call the `type-set` mixin. And there we have it. No longer do I have to define arbitrary breakpoints based on my own assumptions. Using this method, my breakpoints are calculated using a theory, which is always going to beat my own personal judgement. The example provided here is a dumbed down version of the method used on my site, so I recommend you checkout [the code for this website over on GitHub](https://github.com/OliverJAsh/oliverash.me).
