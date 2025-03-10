# ContentHub-Get Asset Page URL From Public Link

## Problem Statement:

On a live website which has assets/images being serviced from Content Hub, we can see the asset URL in the HTML element, which looks like this - https://example.sitecorecontenthub.cloud/api/public/content/0fb562e57bd6442ea144d6131ecbdd87?v=44c12808

From this URL, it is difficult to find out it's Asset Details page in Content Hub. 
This is a challenge when author has to upload a new image and needs to find out the exact dimensions of a similar image on the site.
Also, in cases when author has to edit an asset, like create a new dimension, but cannot find the asset detail page. He/She only knows the public link.

## Solution

This PowerShell script can be executed in local machine. It accepts public link(s) as inout and outputs the corresponding asset page URLs.
Example: https://example.sitecorecontenthub.cloud/en-us/asset/142050
