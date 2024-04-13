# XDEBUG

https://xdebug.org/

https://github.com/xdebug/vscode-php-debug/issues/699

https://stackoverflow.com/questions/71652310/xdebug-not-starting-when-use-the-xdebug-trigger-env-on-vs-code
```json
{
    // Use IntelliSense to learn about possible attributes.
    // Hover to view descriptions of existing attributes.
    // For more information, visit: https://go.microsoft.com/fwlink/?linkid=830387
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Listen for Xdebug",
            "type": "php",
            "request": "launch",
            "port": 9003,
            "env": {
                "XDEBUG_TRIGGER": "true"
            }
        }
    ]
}
```