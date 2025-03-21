#!/usr/bin/env python3
import argparse
import base64
import json
import os
import requests
import sys

def fetch_repository(org, name, token, base_url="https://api.github.com"):
    """Fetch repository details"""
    headers = {
        "Authorization": f"token {token}",
        "Accept": "application/vnd.github.v3+json"
    }
    
    # Normalize base URL
    if base_url.endswith("/"):
        base_url = base_url[:-1]
    if not base_url.startswith("http"):
        base_url = f"https://{base_url}"
    if "api." not in base_url and "github.com" in base_url:
        base_url = base_url.replace("github.com", "api.github.com")
    
    # Get repository info
    url = f"{base_url}/repos/{org}/{name}"
    response = requests.get(url, headers=headers)
    if response.status_code != 200:
        print(f"Error fetching repository: {response.status_code}", file=sys.stderr)
        print(response.text, file=sys.stderr)
        sys.exit(1)
    
    repo_data = response.json()
    return {
        "name": repo_data["name"],
        "description": repo_data["description"] or "",
        "default_branch": repo_data["default_branch"],
        "topics": repo_data.get("topics", []),
        "id": str(repo_data["id"])
    }

def fetch_branch_sha(org, name, branch, token, base_url="https://api.github.com"):
    """Fetch the SHA of the branch"""
    headers = {
        "Authorization": f"token {token}",
        "Accept": "application/vnd.github.v3+json"
    }
    
    # Normalize base URL
    if base_url.endswith("/"):
        base_url = base_url[:-1]
    if not base_url.startswith("http"):
        base_url = f"https://{base_url}"
    if "api." not in base_url and "github.com" in base_url:
        base_url = base_url.replace("github.com", "api.github.com")
    
    # Get branch info
    url = f"{base_url}/repos/{org}/{name}/branches/{branch}"
    response = requests.get(url, headers=headers)
    if response.status_code != 200:
        print(f"Error fetching branch: {response.status_code}", file=sys.stderr)
        print(response.text, file=sys.stderr)
        sys.exit(1)
    
    branch_data = response.json()
    return branch_data["commit"]["sha"]

def fetch_tree(org, name, sha, token, recursive=True, base_url="https://api.github.com"):
    """Fetch the tree of a repository"""
    headers = {
        "Authorization": f"token {token}",
        "Accept": "application/vnd.github.v3+json"
    }
    
    # Normalize base URL
    if base_url.endswith("/"):
        base_url = base_url[:-1]
    if not base_url.startswith("http"):
        base_url = f"https://{base_url}"
    if "api." not in base_url and "github.com" in base_url:
        base_url = base_url.replace("github.com", "api.github.com")
    
    # Get tree
    url = f"{base_url}/repos/{org}/{name}/git/trees/{sha}"
    if recursive:
        url += "?recursive=1"
    
    response = requests.get(url, headers=headers)
    if response.status_code != 200:
        print(f"Error fetching tree: {response.status_code}", file=sys.stderr)
        print(response.text, file=sys.stderr)
        sys.exit(1)
    
    tree_data = response.json()
    # Only include blob type items (files)
    files = [item for item in tree_data["tree"] if item["type"] == "blob"]
    return files

def fetch_file_content(org, name, path, branch, token, base_url="https://api.github.com"):
    """Fetch the content of a file"""
    headers = {
        "Authorization": f"token {token}",
        "Accept": "application/vnd.github.v3+json"
    }
    
    # Normalize base URL
    if base_url.endswith("/"):
        base_url = base_url[:-1]
    if not base_url.startswith("http"):
        base_url = f"https://{base_url}"
    if "api." not in base_url and "github.com" in base_url:
        base_url = base_url.replace("github.com", "api.github.com")
    
    # Get file content
    url = f"{base_url}/repos/{org}/{name}/contents/{path}?ref={branch}"
    response = requests.get(url, headers=headers)
    if response.status_code != 200:
        print(f"Error fetching file content: {response.status_code}", file=sys.stderr)
        print(response.text, file=sys.stderr)
        sys.exit(1)
    
    content_data = response.json()
    if content_data.get("encoding") == "base64":
        return content_data.get("content", "")
    else:
        print(f"Unexpected encoding: {content_data.get('encoding')}", file=sys.stderr)
        return ""

def main():
    parser = argparse.ArgumentParser(description="Fetch GitHub repository details")
    parser.add_argument("--org", required=True, help="GitHub organization")
    parser.add_argument("--name", required=True, help="Repository name")
    parser.add_argument("--token", help="GitHub token")
    parser.add_argument("--base-url", default="https://api.github.com", help="GitHub API base URL")
    parser.add_argument("--output-dir", default=".", help="Directory to save output files")
    parser.add_argument("--action", choices=["repo", "tree", "file"], required=True, help="Action to perform")
    parser.add_argument("--branch", help="Branch name (for file or tree actions)")
    parser.add_argument("--sha", help="Commit SHA (for tree action)")
    parser.add_argument("--path", help="File path (for file action)")
    
    args = parser.parse_args()
    
    # Get token from environment if not provided
    token = args.token or os.environ.get("GITHUB_PUBLIC_TOKEN")
    if not token:
        print("GitHub token is required. Provide --token or set GITHUB_TOKEN env var.", file=sys.stderr)
        sys.exit(1)
    
    if args.action == "repo":
        repo_data = fetch_repository(args.org, args.name, token, args.base_url)
        print(json.dumps(repo_data))
    
    elif args.action == "tree":
        if not args.branch and not args.sha:
            print("Either --branch or --sha is required for tree action", file=sys.stderr)
            sys.exit(1)
        
        # Get the SHA if only branch is provided
        if not args.sha and args.branch:
            args.sha = fetch_branch_sha(args.org, args.name, args.branch, token, args.base_url)
        
        tree_data = fetch_tree(args.org, args.name, args.sha, token, True, args.base_url)
        print(json.dumps(tree_data))
    
    elif args.action == "file":
        if not args.path or not args.branch:
            print("Both --path and --branch are required for file action", file=sys.stderr)
            sys.exit(1)
        
        content = fetch_file_content(args.org, args.name, args.path, args.branch, token, args.base_url)
        print(json.dumps({"content": content}))

if __name__ == "__main__":
    main()