#!/bin/bash

#We make sure we run this just at one before_deploy hook.
if ! [ "$BEFORE_DEPLOY_RUN" ] && [ "$TRAVIS_PHP_VERSION" == "$DEPLOY_BUILD" ]; then

        echo " Preparing deploy. ";

    # Flag the run.
        export BEFORE_DEPLOY_RUN=1;

    # Parse the name of the repo.
        export THEMEISLE_REPO
        THEMEISLE_REPO=$(node -pe "require('./package.json').name")

    # Parse the version of the product.

        export THEMEISLE_VERSION
        THEMEISLE_VERSION=$(node -pe "require('./package.json').version")

    # Parse product category.
        export THEMEISLE_CATEGORY
        THEMEISLE_CATEGORY=$(node -pe "require('./package.json').category")

        export DEMO_THEMEISLE_PATH
        DEMO_THEMEISLE_PATH="/sites/demo.themeisle.com/wp-content/$THEMEISLE_CATEGORY/$THEMEISLE_REPO";

    # Build changelog based on commit message description.
        CHANGELOG="\n ### v$THEMEISLE_VERSION - $(date +'%Y-%m-%d') \n **Changes:** \n";

    # Remove first line from the commit as is it used as commit title.
        NORMALIZED_MESSAGE=$(sed "1d"  <<< "$TRAVIS_COMMIT_MESSAGE");

    # Save changes list in a sepparately variable as we use it in the release body.
        export CHANGES="";
        while read -r line; do
            if ! [ -z "$line" ]; then
                line="${line//[$'\r\n']}";
                export CHANGES=$CHANGES'- '$line'\n';
            fi;
        done <<< "$NORMALIZED_MESSAGE"

    # Concat changes and changelog title and prepend to the changelog file.

        CHANGELOG="$CHANGELOG $CHANGES";
        echo -e "$CHANGELOG $(cat CHANGELOG.md)" > CHANGELOG.md

    # Run the prepare deployment action
        openssl aes-256-cbc -K $encrypted_030a3191f4c5_key -iv $encrypted_030a3191f4c5_iv -in key.enc -out key -d
        grunt deploy
fi;