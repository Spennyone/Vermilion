Vermilion
=========

In-development administration tool for Garry's Mod servers.

The main aim for Vermilion is to have something that is powerful yet permissive.

In the scope of Vermilion, permissive is defined as:
* allowing other addons to use hooks when possible instead of returning a value regardless
* doesn't require any other addons to function
* works out-of-the-box with zero-configuration and intelligent defaults, but highly customisable when required
* players need not know that Vermilion is installed on the server unless they get on the wrong side of the admins

Vermilion is designed in a modular nature. This means that each major piece of functionality is stored in its own module (referred to by Vermilion as an "extension"). Vermilion should continue to operate regardless of what extensions are loaded. This means that all extensions should be SELF SUFFICIENT without depending on each other, and if they do, it should be a soft dependency so it quietly fails without producing an error.

Do not upload to the Steam Workshop without my permission.
