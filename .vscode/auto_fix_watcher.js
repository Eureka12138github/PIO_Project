// Auto-fix c_cpp_properties.json on save
// This script watches for changes to c_cpp_properties.json and automatically fixes path issues

const fs = require('fs');
const path = require('path');

const workspaceFolder = process.env.VSCODE_WORKSPACE_FOLDER || process.cwd();
const cppPropertiesPath = path.join(workspaceFolder, '.vscode', 'c_cpp_properties.json');

console.log(`Watching: ${cppPropertiesPath}`);

// Watch the file
fs.watch(cppPropertiesPath, (eventType) => {
    if (eventType === 'change') {
        console.log('File changed. Waiting 500ms before fixing...');
        
        // Wait a bit to ensure the write is complete
        setTimeout(() => {
            fixCppProperties();
        }, 500);
    }
});

function fixCppProperties() {
    try {
        let content = fs.readFileSync(cppPropertiesPath, 'utf8');
        const originalContent = content;
        
        // Define path replacements
        const replacements = [
            {
                pattern: /D:\\\\Embedded-related\\\\PIO\\\\PIO_HAL_PROJECT_TEMPLATE\\\\Embedded-relatedPIOPIO_HAL_PROJECT_TEMPLATE\\\\include/g,
                replacement: '${workspaceFolder}/include'
            },
            {
                pattern: /D:\\Embedded-related\\PIO\\PIO_HAL_PROJECT_TEMPLATE\\Embedded-relatedPIOPIO_HAL_PROJECT_TEMPLATE\\include/g,
                replacement: '${workspaceFolder}/include'
            },
            {
                pattern: /D:\\\\Embedded-related\\\\PIO\\\\PIO_HAL_PROJECT_TEMPLATE\\\\Embedded-relatedPIOPIO_HAL_PROJECT_TEMPLATE\\\\src\\\\Drivers/g,
                replacement: '${workspaceFolder}/src/Drivers'
            },
            {
                pattern: /D:\\Embedded-related\\PIO\\PIO_HAL_PROJECT_TEMPLATE\\Embedded-relatedPIOPIO_HAL_PROJECT_TEMPLATE\\src\\Drivers/g,
                replacement: '${workspaceFolder}/src/Drivers'
            },
            {
                pattern: /D:\\\\Embedded-related\\\\PIO\\\\PIO_HAL_PROJECT_TEMPLATE\\\\Embedded-relatedPIOPIO_HAL_PROJECT_TEMPLATE\\\\src\\\\Drivers\\\\Display/g,
                replacement: '${workspaceFolder}/src/Drivers/Display'
            },
            {
                pattern: /D:\\Embedded-related\\PIO\\PIO_HAL_PROJECT_TEMPLATE\\Embedded-relatedPIOPIO_HAL_PROJECT_TEMPLATE\\src\\Drivers\\Display/g,
                replacement: '${workspaceFolder}/src/Drivers/Display'
            },
            {
                pattern: /D:\\\\Embedded-related\\\\PIO\\\\PIO_HAL_PROJECT_TEMPLATE\\\\Embedded-relatedPIOPIO_HAL_PROJECT_TEMPLATE\\\\src\\\\Drivers\\\\Display\\\\Fonts/g,
                replacement: '${workspaceFolder}/src/Drivers/Display/Fonts'
            },
            {
                pattern: /D:\\Embedded-related\\PIO\\PIO_HAL_PROJECT_TEMPLATE\\Embedded-relatedPIOPIO_HAL_PROJECT_TEMPLATE\\src\\Drivers\\Display\\Fonts/g,
                replacement: '${workspaceFolder}/src/Drivers/Display/Fonts'
            },
            {
                pattern: /D:\\\\Embedded-related\\\\PIO\\\\PIO_HAL_PROJECT_TEMPLATE\\\\include/g,
                replacement: '${workspaceFolder}/include'
            },
            {
                pattern: /D:\\Embedded-related\\PIO\\PIO_HAL_PROJECT_TEMPLATE\\include/g,
                replacement: '${workspaceFolder}/include'
            },
            {
                pattern: /D:\\\\Embedded-related\\\\PIO\\\\PIO_HAL_PROJECT_TEMPLATE\\\\src/g,
                replacement: '${workspaceFolder}/src'
            },
            {
                pattern: /D:\\Embedded-related\\PIO\\PIO_HAL_PROJECT_TEMPLATE\\src/g,
                replacement: '${workspaceFolder}/src'
            }
        ];
        
        // Apply all replacements
        replacements.forEach(({pattern, replacement}) => {
            content = content.replace(pattern, replacement);
        });
        
        // Remove empty strings from arrays
        content = content.replace(/,\s*""\s*\]/g, ']');
        
        // Only write if changed
        if (content !== originalContent) {
            fs.writeFileSync(cppPropertiesPath, content, 'utf8');
            console.log('✓ Fixed c_cpp_properties.json');
        } else {
            console.log('✓ No changes needed');
        }
    } catch (error) {
        console.error('Error fixing file:', error.message);
    }
}

console.log('Watcher started. Press Ctrl+C to stop.');
