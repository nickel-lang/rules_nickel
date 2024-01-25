import httpx
import hashlib
import base64
from github import Github, Auth

ASSET_NAMES = [ "nickel-x86_64-linux", "nickel-arm64-linux" ]

def collect_asset_urls(github_releases):
    nickel_releases = {}
    for release in github_releases:
        if release.tag_name.startswith("1."):
            nickel_releases[release.tag_name] = {}
            for asset in release.assets:
                if asset.name in ASSET_NAMES:
                    nickel_releases[release.tag_name][asset.name] = {
                        "url": asset.browser_download_url
                    }
    return nickel_releases

def hash_url(url):
    r = httpx.get(url, follow_redirects=True)
    r.raise_for_status()
    hash = hashlib.sha384(r.content).digest()
    return f'sha384-{base64.b64encode(hash).decode()}'

def hash_assets(assets):
    r = {}
    for asset, d in assets.items():
        r[asset] = {
            "url": d["url"],
            "hash": hash_url(d["url"]),
        }

    return r

token = os.environ.get('GITHUB_TOKEN')
if token:
    github = Github(auth=Auth.Token(token))
else:
    github = Github()

releases = github.get_repo("tweag/nickel").get_releases()
nickel_urls = collect_asset_urls(releases)

nickel_releases = {}

for release, assets in nickel_urls.items():
    nickel_releases[release] = hash_assets(assets)

print('''
"""DO NOT EDIT

Generated from https://github.com/tweag/nickel/releases using `bazel run //nickel/private:versions.update`
"""

TOOL_VERSIONS = {''')

for release, assets in nickel_releases.items():
    if not assets:
        continue
    print(f'    "{release}": {{')
    for key, asset in assets.items():
        print(f'''\
        "{key}": {{
            "url": "{asset["url"]}",
            "hash": "{asset["hash"]}",
        }},''')
    print('    },')
    
print("}")
