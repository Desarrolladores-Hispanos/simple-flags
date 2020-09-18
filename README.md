# Plugin: `simple-flags`

Changes the mechanism of auto-hiding posts based on flags to use a fixed threshold for flag count, rather than a flagging score.

---

## Features

- Changes the mechanism of auto-hiding posts based on flags submitted by forum users.

  - Discourse uses a flag scoring system to give a weight to each flag, that is based on trust level of the flagging user, as well as their past flagging accuracy (influenced by how many of the past 100 flags of that user the moderators approved, ignored or denied their flag).

  - Normally, posts are automatically hidden when the cumulative score of these flags exceeds a given value.

  - This plugin overrides this mechanism and instead uses a threshold for flag count to determine when to hide a post, i.e. treats each flag as having the same score of 1.

  - The threshold can be set on both a forum-wide level and a per-category level.

---

## Impact

### Community

Previously, a post could be auto-hidden by a varying number of flags, which caused undesirable results of some users being able to hide a post with just one flag.

Now, posts will be hidden much less frequently, making moderation seem less invasive and less emphasis on bad posts/authors, which hopefully leads to less toxic reactions within the community.

### Internal

There is less stress on forum moderation to process flags as quickly as possible, because the threshold for when a post is automatically hidden can be put much higher.

There is no effect on the actual way how flags are handled. This plugin does not alter the way flags appear in the flag review part of the website nor changes the way how flags are addressed. It just affects auto-hiding of posts.

### Resources

None, if anything it makes the auto-hiding checks cheaper than stock Discourse.

### Maintenance

Developer Relations might want to update the settings for the flag counts over time, as the forum gain more users that are able to flag posts.

---

## Technical Scope

The plugin uses standard recommended functionality for extending category settings and ensuring they serialize properly to admin users when configuring the category. It also extends the Category class by adding an extra field to it that reflects the category setting.

Furthermore, the plugin intervenes in the function that is responsible for auto-hiding a post after a flag has been added to the post.

The prepend mechanism that is used to intervene in this function is a standard one, and so is unlikely to break throughout Discourse updates, with the exception of the case where the name or parameter list of `PostActionCreator.auto_hide_if_needed` changes. Even if that happens, the forum will continue to function properly, only the plugin functionality will be broken and the old auto-hiding mechanism takes effect instead.

Inside the function, the original function is invoked if the plugin is disabled, and otherwise the logic is entirely overridden so that it uses a count threshold rather than a score threshold. It only counts actual moderation flags and not events where the user submitted a message to a user via the flag window.

---

## Configuration

The default number of flags required to hide a post can be configured via the `default_flags_required` setting (default: 5).

Furthermore, the threshold can be overridden on a per-category basis, by setting Settings > "Number of flags required to hide post". To use the forum-wide threshold again, simply clear this value.

#### Copyright 2020 Roblox Corporation
