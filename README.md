# quilt.com

A tiled slideshow application. Built with [redbean.dev](https://redbean.dev), which means the whole application is deployed as a single <6MB file 🤏.

<video src="https://github.com/user-attachments/assets/0929765f-b850-4eb1-b661-27b42b2d3e3b" autoplay="true" controls="false"></video>

*Images in video by [haggle](https://bsky.app/profile/idarzikfth.bsky.social).*

## Usage

Make sure `quilt.com` is executable:

```bash
# Make sure quilt.com is executable
chmod +x quilt.com

# Run on port 8082
quilt.com -p 8082 /home/kevin/Pictures/italy_vacation --interval=3 --rows=5 --columns=3 --video-rate
```

Options:
* `--interval` - How often (in seconds) should a new image be loaded (defaults to 2s)
* `--rows` - How many rows to display (Defaults to 3)
* `--columns` - How many columns to display (Defaults to 4)
* `--video-rate` - How often to load videos (Defaults to 1; set to 0 to display videos)

## Development

System dependencies required for building:

* `make`
* `zip`

Note: [watchexec](https://github.com/watchexec/watchexec) is required for `make watch` to work.

```bash
# download dev dependencies
make download

# run
make run

# or start service and watch for changes
make watch
```

## TODO

* [ ] allow for relative paths
* [ ] allow for multiple dirs
* [ ] use a proper args parser
* [ ] customize image aspect ratio via arg
* [ ] proper gui
