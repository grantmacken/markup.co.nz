Responsive CSS Grid System
--------------------------

For 'get it out the door' [rapid
prototyping](http://www.smashingmagazine.com/2010/06/16/design-better-faster-with-rapid-prototyping/)
( no wireframe developing with a browser refresh in view ) it's best to use a
css grid system. Grid systems have been around for a while. Blueprint , 960 etc.
Now we are in the age of *media queries* coupled with *responsive grids* and
*css preprocessors* helping to do the Math. In our sass workspace environment we
have grid systems like zen, salsa, sassy and singularity. Sassy-next is most
likely what will be adopting in the future but in the meantime we will use
singularitygs. Our layouts need to respond to *Media Queries* so we use
[singularitygs](https://github.com/Team-Sass/Singularity) with [breakpoint
slicer](https://github.com/lolmaus/breakpoint-slicer). Breakpoint slicer provide
an alternative syntax to [breakpoint](https://github.com/Team-Sass/breakpoint)

When responding to media queries with breakpoints we can take
[device](http://astronautweb.co/2012/01/responsive-web-design-four-states/) or
[device
agnostic](http://coding.smashingmagazine.com/2012/03/22/device-agnostic-approach-to-responsive-web-design/)
approach. The
[arguments](http://tangledindesign.com/deciding-what-responsive-breakpoints-to-use/)
for a 'device agnostic' seem solid enough so lets go down that route.

What we do have to look at is some reusable [layout
patterns](http://www.lukew.com/ff/entry.asp?1514) for multiple devices and how
we handle
['navigation'](http://bradfrostweb.com/blog/web/complex-navigation-patterns-for-responsive-design/)
in small screen devices.

Home Page
---------

Our home page layout structure are driven by our 'page templates'. e.g. <br/>
```/templates/pages/home.html`` <br/>
generates a sectioned layout, attributed with aria landmark roles

* body/header[@role='banner'] implicit site navigation
* body/nav[@role='navigation'] implicit site wide navigation
* body/article[@role='main']
* body/footer[@role="contentinfo"]

If we define our breakpoints like this<br/> ```$slicer-breakpoints: 0 400px
600px 800px 1050px;``` <br/> we get 5 breakpoints. With these breakpoints, we
can then allow the layout to **shift** as it adapts to various screen sizes

Our **homepage** just a simple 'section' stack with no asides so at our
breakpoints we are not going to shift sections around but adjust how sections
span our grid

    header[role='banner'],
    footer[role="contentinfo"],
    nav[role='navigation'],
    article[role='main']{
      @include at(5) {
        @include grid-span(10, 2); clear: both;
        }
       @include at(4) {
        @include grid-span(7, 2); clear: both;
        }
       @include at(3) {
        @include grid-span(6); clear: both; } @include between(1,2) {
            @include
            grid-span(3); clear: both;
            }
    }


and adjust some element styling within our sections so it best fits our adusted
screen size. e.g.

    h1{
    text-shadow: -1px 0 0 $title-text-shadow, 1px 1px 0 $title-text-shadow,
    2px -1px 0 $title-text-shadow, 3px 0 0 $title-text-shadow;

    @include at(5) {
     letter-spacing: 30px;
     }

    @include at(4) {
        letter-spacing: 20px;
        }

    @include at(3) {
        padding-left: .5em; letter-spacing: 10px;
        }

     @include between(1, 2) {
        @include adjust-font-size-to(24px);
        letter-spacing: 2px;
        margin-left : .5em ;
        }
    }

and can also float our nav list items into our grid using ```gutter-span```
and  ```column-span`` functions provided by singularitygs

    li{
    display: block;
    float:left;
     @include at(5) {
     width: column-span(2, 1, $grid: 10 );
     margin-right: gutter-span($grid: 10 );
     }

    @include at(4) {
     width: column-span(2, 1, $grid: 7 );
     margin-right: gutter-span($grid: 7 );
     }

    @include at(3) {
     width: column-span(2, 1, $grid: 6 );
     margin-right: gutter-span($grid: 6 );
     }

     @include between(1, 2) {
     width: column-span(1, 1, $grid: 3 );
     margin-right: gutter-span($grid: 3 );
     }


