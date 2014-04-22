

Tests cases cut and paste from  [authorship-test-cases](https://github.com/sandeepshetty/authorship-test-cases)

[no h-card]( http://markup.co.nz/_tests/no_h-card ) <br/>

    xml
	<p>Nothing to see here. Move along.</p>

should fail   OK

<hr/>

[h-entry with p-author]( http://markup.co.nz/_tests/h-entry_with_p-author ) <br/>

    xml
	<div class="h-entry">
	    <div class="p-author h-card">
		<a class="u-url" href="http://example.com/johndoe/"><img class="u-photo" src="http://www.gravatar.com/avatar/fd876f8cd6a58277fc664d47ea10ad19.jpg?s=80&amp;d=mm"></a>

		<p class="p-name">John Doe</p>
	    </div>

	    <div class="p-name p-summary e-content">
		Hello World!
	    </div>
	</div>

should succeed OK

<hr/>

Assumption: The page is a permalink

1. parse the h-entry for the post on the page. if no h-entry, then there's no post to find authorship for, abort. <br/>[no h-card]( http://markup.co.nz/_tests/no_h-card )
should fail   OK

2. if the h-entry has a p-author, use that and its h-card to determine the author of the post. <br/> [h-entry with p-author]( http://markup.co.nz/_tests/h-entry_with_p-author )
should succeed   OK


<div class="h-card">
<a class="u-url" rel="author" href="no_h-card.html">
<img class="u-photo" src="http://www.gravatar.com/avatar/fd876f8cd6a58277fc664d47ea10ad19.jpg?s=80&d=mm">
</a>
<p class="p-name">John Doe</p>
</div>
<div class="h-entry">
<div class="p-name p-summary e-content">Hello World!</div>
</div>
