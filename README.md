# Live Music from Nostr (NIP-38)

Live music statuses via Nostr [NIP-38](https://github.com/nostr-protocol/nips/blob/master/38.md) based on [this idea](https://iris.to/note1awq98ydrr809907pmk99tmyqyx3h0qrchgh6jt8s639rwcsl260su2pphp) by @SamSamskies 

The idea is to make a mini web app.

## To Do
* BUG: Order by creation date aggregate of all relays (seems that we are waiting for the userdata to arrive before adding stuff, so... this is async, which results in different and rather random orders.)
* See connected relays.
* Edit relays list.
* Login using a nip-07 extension to see a feed from just the people a user is following via the Connect button.
* Pull down update.
* Create a class for userdata instead of using the json response directly.
* For the wavlake links you could even easily display an embedded music player using an iframe. here's how snort does that github.com/v0l/snort/blob/main/packages/app/src/Element/Embed/WavlakeEmbed.tsx. snort also has code to display apple music and spotify embeds if you wanna use that [note](https://iris.to/note1drtnmusdh6r2x25pqlvddgctg5u8trlmqu9v0jq5c3xnludltv3s0z5mt6).

## Changelog
* v0.0.1 - Starting up!