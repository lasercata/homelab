# WordPress
[WordPress](https://wordpress.org) is a content management system (blog/site creation)

## Setup
Create the `.env` from the example:
```
cp .env.default .env
```

Update the values:
- `db_user_password`: set the password
- `db_random_root_password`: set a random password

In the domain manager, add a line:
| Sub-domain | TTL  | Type | Value        |
| ---------- | ---- | ---- | ------------ |
| wordpress  | 3600 | A    | [Server IP]  |

Or not if you want to redirect directly from the root of the domain.


In the nginx proxy manager, add a *proxy host*:
```
Domain name: wordpress.domain.tld
Scheme: http
Forward Hostname / IP: wordpress
Forward Port: 80
SSL Certificate (SSL tab): request a new certificate
```

Then launch the docker:
```
docker compose up -d
```

Then navigate to the site, and make the configuration.

## Permissions
To allow accounts with the *editor* role to edit the whole site, you need to add this code.

Where? In the file `volumes/wordpress/data/wp-content/themes/twentytwentyfive/functions.php`.
Replace `twentytwentyfive` with the name of your currently used theme.

What?
```
function allow_editor_theme_options() {
    // Get the Editor role object
    $role = get_role('editor');

    // Add the capability to edit theme options (Menus, Widgets, Customizer)
    if ($role) {
        $role->add_cap('edit_theme_options');
    }
}
// Run this function once (e.g., on theme switch or manually trigger once)
// add_action('after_switch_theme', 'allow_editor_theme_options');
add_action('init', 'allow_editor_theme_options');
```

