== README

ruby 2.2
node v0.10.26

Are you seeing?
```
ActionView::Template::Error:         ActionView::Template::Error: couldn't find file 'main.bundle' with type 'application/javascript'
```

This is because main.bundle.js is in the .gitignore for reasons that have to do with it changing all the time. Run

```
touch app/assets/javascripts/main.bundle.js
```
to fix.

In the future we're going to want to check it in blank and run "assume unchanged" locally so git never bugs us to check in changes everytime we compile assets. This can be done with

```
 git update-index --assume-unchanged app/assets/javascripts/main.bundle.js
```

To run, install packages and then:
`be rails s -p 4000`
`npm run webpack-w`
