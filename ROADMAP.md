TSMarkdownParser
================

Roadmap of future features. Contributors are welcome.

#Features

## Supported parsers

* StandardParser is currently the only pre-defined parser. It is inspired by [Daring Fireball](http://daringfireball.net/projects/markdown/syntax).

We may or may not add support for other markup parsers. Help welcome.

Markup-like languages references:
* https://en.wikipedia.org/wiki/Lightweight_markup_language
* [Xcode-Markup](https://developer.apple.com/library/mac/documentation/Xcode/Reference/xcode_markup_formatting_ref/)
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
Priority. Maybe TSMarkdown 3.1.

## Swift
We will embrace Swift 3.0 for TSMarkdown 4.0.

## Grammar and Lexer parsing
Maybe one day with TSMarkdown 5.0.

## Will probably not support
* Full HTML5 support makes no sense
* complex logic on how to encompass a word, like defined by CommonMark: it is unintuitive as it requires too much lookahead to satisfy. Using character escaping with '\' is a better solution.
* context dependent list or quote system: it requires too much lookbehind to satisfy. Context independent list/quote system is an easier solution.

#Third parties

## Emoji

* For [emoji-cheat-sheet](http://www.emoji-cheat-sheet.com/), you can simply use '[NSStringEmojize](https://github.com/diy/nsstringemojize)' available on CocoaPods

## Clicking on elements on UILabel

You can try an UITextView for a start. Or:
* [TTTAttributedLabel](https://github.com/TTTAttributedLabel/TTTAttributedLabel) 1.8.1 ([later versions have alignment issues](https://github.com/TTTAttributedLabel/TTTAttributedLabel/issues/658))
* [KILabel](https://github.com/Krelborn/KILabel)
