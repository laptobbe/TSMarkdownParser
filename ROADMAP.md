TSMarkdownParser
================

Roadmap of future features. Contributors are welcome.

#Features

## Supported parsers

* StandardParser is currently the only pre-defined parser. It is inspired by [Daring Fireball](http://daringfireball.net/projects/markdown/syntax).

We may or may not add support for other markup parsers. Help welcome.

Markdown-like languages references:
* [GitHub-flavored](https://guides.github.com/features/mastering-markdown/)
* [BitbucketServer](https://confluence.atlassian.com/bitbucketserver/markdown-syntax-guide-776639995.html)
* [StackOverflow](https://stackoverflow.com/editing-help)
* [MultiMarkdown](https://rawgit.com/fletcher/human-markdown-reference/master/index.html)
* [CommonMark](http://spec.commonmark.org/)
* [Kramdown](http://kramdown.gettalong.org/syntax.html)
* [Texttile](https://github.com/textile/textile-spec)
* [Setext](https://en.wikipedia.org/wiki/Setext)
* [Skype](https://community.skype.com/t5/Windows-desktop-client-Ideas/Text-formatting-for-chat/idi-p/3208296)

Wiki-like references:
* [Mediawiki](https://www.mediawiki.org/wiki/Help:Formatting)
* [JiraWiki](https://jira.atlassian.com/secure/WikiRendererHelpAction.jspa?section=all)

BBCode-like references:
* [BBCode](http://www.bbcode.org/reference.php)
* [phpBB](https://www.phpbb.com/community/faq.php?mode=bbcode)
* [vBulletin](https://www.vbulletin.org/forum/misc.php?do=bbcode)

HTML:
* HTML safe subset

## NSAttributedString to Markdown

In progress.

## Swift

We will embrace Swift 3.0 when available (probably after WWDC2016).

## Grammar and Lexer parsing

Maybe or maybe not...


#Third parties

## Emoji

* For [emoji-cheat-sheet](http://www.emoji-cheat-sheet.com/), you can simply use '[NSStringEmojize](https://github.com/diy/nsstringemojize)' available on CocoaPods

## Clicking on elements on UILabel

You can try an UITextView for a start. Or:
* [TTTAttributedLabel](https://github.com/TTTAttributedLabel/TTTAttributedLabel) 1.8.1 ([later versions have alignment issues](https://github.com/TTTAttributedLabel/TTTAttributedLabel/issues/658))
* [KILabel](https://github.com/Krelborn/KILabel)
