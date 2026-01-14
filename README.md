HN Personal Websites Directory
==============================

HN Personal Websites Directory (HNPWD) is a community-maintained
directory of personal websites by members of the Hacker News (HN)
community, along with an OPML file containing their RSS feeds.  Please
visit the following link to view these resources:

* Directory Website: [hnpwd.github.io][site]
* RSS Feeds OPML: [pwd.opml][opml]

[site]: https://hnpwd.github.io/
[opml]: https://hnpwd.github.io/pwd.opml
[lisp]: pwd.lisp


Contents
--------

* [Add Your Website](#add-your-website)
  * [Criteria](#criteria)
  * [Add](#add)
* [Maintainers Needed](#maintainers-needed)
* [FAQ](#faq)
* [Licence](#licence)
* [Contact](#contact)


Add Your Website
----------------

### Criteria

Please check whether a website meets the following criteria before
requesting its inclusion in the directory:

 1. The website must be a personal website, where the author of the
    website has full control of its design and content.  Websites
    hosted on personal domains clearly qualify.  Websites hosted on
    services such as Neocities, GitHub Pages or Codeberg Pages also
    qualify, as these platforms allow full control over the site's
    design.  However, blogs hosted on publishing platforms such as
    Medium or Substack do not qualify.

 2. Visit https://news.ycombinator.com/from?site=example.com and
    replace `example.com` in the URL the website's domain.  Review the
    posts from the website with the highest point totals.  The website
    qualifies if five or fewer posts have a combined total of at least
    100 points.

    For example, a website that has a single HN post with 100 points
    qualifies.  A website with two HN posts with 60 and 40 points
    respectively also qualify.  However, a website with seven HN posts
    with 15 points each does not qualify.  Put another way, this
    criterion looks for an average of at least 20 points per post
    across the top five posts from the website on HN.

If a website satisfies both criteria above, proceed with the
submission process laid out in the next section.  These requirements
help ensure that our directory remains interesting and substantive.
They prevent our directory from becoming a collection of minimal or
placeholder websites with little content of value to the community.

If a website does not satisfy the above criteria but you think it is
still quite interesting (for example, it has interesting posts, games
etc.), please make a request to add it anyway.  If it looks
interesting enough, we may still add it.


### Add

Add the website details to [pwd.lisp][lisp] and submit a pull request.

An example entry is provided at the bottom of the [pwd.lisp][lisp]
file and can be copied and modified as a starting point.  When
creating a pull request, please follow these guidelines:

 1. Keep all website entries sorted alphabetically by name.

 2. Ensure that the bio text does not exceed 80 characters.

 3. If certain information is not available or should not be included,
    remove the corresponding property entirely.  For example, if no
    'about' link exists, delete the entire `:about` line from the
    entry.

Alternatively, [create an issue][ISSUES] and post the website details
in the following format:

````lisp
```
 (:name "Your first name and last name"
  :site "https://example.com/"
  :blog "https://example.com/blog/ (Only if you have a separate blog URL)"
  :feed "https://example.com/feed.xml"
  :about "https://example.com/about/"
  :now "https://example.com/now/"
  :hnuid "example (Your HN user ID)"
  :bio "A brief third-person description of yourself, not exceeding 80 characters.")
```
````

That's it!  Once you create the PR or the issue, we'll take care of
the rest.

[HN]: HN


Maintainers Needed
------------------

This project needs additional contributors to help review and merge
pull requests so that the website list maintained in this project can
grow in a timely manner.

If you are an active member of the Hacker News community with a solid
history of participation, such as multiple submissions reaching the
front page and an active comment history, we would be glad to hear
from you.  Please reach out on [IRC][] so that we can discuss granting
review and merge access.


FAQ
---

 1. How is this different from the OPML available at
    [outcoldman/hackernews-personal-blogs][outcoldman]?

    The OPML file there is more comprehensive.  It currently includes
    over 1200 RSS feeds, whereas our project only has a small number
    of entries so far.  We hope that, with contributions from
    community members, our list will grow over time.  An important
    goal of this project is to maintain the list of websites together
    as a community.

    This project also goes beyond providing an OPML file.  In addition
    to the [OPML][opml], it offers a [website][site] that lists the
    websites individually along with a short bio of each author.

 2. Why did you not start by importing
    [outcoldman/hackernews-personal-blogs][outcoldman]?

    We have not yet had the time to do so.  The [data format][lisp]
    used by this project differs from theirs and requires additional
    information for each blog entry.  Translating the existing list
    into our format therefore takes a non-trivial amount of effort,
    which we have not been able to commit to yet.

    Contributions that add entries to this project, whether sourced
    from that list or elsewhere, are very welcome.

[outcoldman]: https://github.com/outcoldman/hackernews-personal-blogs


Licence
-------

This is free and open source software.  You can use, copy, modify,
merge, publish, distribute, sublicence and/or sell copies of it, under
the terms of the MIT Licence.  See [LICENSE.md][L] for details.

This software is provided "AS IS", WITHOUT WARRANTY OF ANY KIND,
express or implied.  See [LICENSE.md][L] for details.

[L]: LICENSE.md


Contact
-------

To report bugs or ask questions, [create issues][ISSUES].

Alternatively, you can also join our IRC channel [#hnpwd][IRC] on
Libera Chat to ask questions or just generally hang out with the
community.

[ISSUES]: https://github.com/hnpwd/hnpwd.github.io/issues
[IRC]: https://web.libera.chat/#hnpwd
