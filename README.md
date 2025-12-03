# <a href="https://swagger-ui-public.web.app" target="_blank" rel="noopener noreferrer">swagger-ui-public.web.app</a>
A publicly hosted [swagger-ui](https://github.com/swagger-api/swagger-ui) with query enabled.

`swagger-ui version 5.30.3`

## Details
Hosted on Firebase.

`make deploy` will fetch the swagger-ui bundle, unpack the dist directory, set `queryConfigEnabled: true`, then deploy to Firebase.

Any forks of this repo will need to modify `.firebaserc` to point to their own Firebase project.
