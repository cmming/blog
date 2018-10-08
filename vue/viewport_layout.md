### vw 解决方案 替代 flexible 

 
    解决途径：1.使用将所有的元素的高度都采用vh这种单位或者宽度为vw。 
             2.postcss-aspect-ratio-mini主要用来处理元素容器宽高比。



### 安装 PostCSS插件
    ##默认已安装的插件
    postcss-import 解决@import引入路径问题
    postcss-url 处理文件，比如图片文件、字体文件等引用路径的处理
    autoprefixer 浏览器前缀


### 实现 vw要安装的插件
    postcss-aspect-ratio-mini ：处理元素容器宽高比
    postcss-px-to-viewport：把px单位转换为vw、vh、vmin或者vmax这样的视窗单位 
    postcss-write-svg：
    postcss-cssnext ：使用CSS未来的特性，其会对这些特性做相关的兼容性处理
    cssnano：压缩和清理CSS代码
    postcss-viewport-units

    npm i postcss-aspect-ratio-mini postcss-px-to-viewport postcss-write-svg postcss-cssnext postcss-viewport-units cssnano --S 


    修改配置文件 .postcssrc.js

    // https://github.com/michael-ciniawsky/postcss-load-config

    module.exports = {
    "plugins": {
        "postcss-import": {},
        "postcss-url": {},
        "postcss-aspect-ratio-mini": {}, 
        "postcss-write-svg": {
            utf8: false
        },
        "postcss-cssnext": {},
        "postcss-px-to-viewport": {
            viewportWidth: 750,     // (Number) The width of the viewport.
            viewportHeight: 1334,    // (Number) The height of the viewport.
            unitPrecision: 3,       // (Number) The decimal numbers to allow the REM units to grow to.
            viewportUnit: 'vw',     // (String) Expected units.
            selectorBlackList: ['.ignore', '.hairlines'],  // (Array) The selectors to ignore and leave as px.
            minPixelValue: 1,       // (Number) Set the minimum pixel value to replace.
            mediaQuery: false       // (Boolean) Allow px to be converted in media queries.
        }, 
        "postcss-viewport-units":{},
        "cssnano": {
            preset: "advanced",
            autoprefixer: false,
            "postcss-zindex": false
        },
    }
    }


#### cssnano 压缩和清理CSS代码 再配置中使用  preset: "advanced"

    需要另外安装 npm i cssnano-preset-advanced --save-dev


#### postcss-px-to-viewport：插件主要用来把px单位转换为vw、vh、vmin或者vmax这样的视窗单位 


        "postcss-px-to-viewport": { 
            viewportWidth: 750, // 视窗的宽度，对应的是我们设计稿的宽度，一般是750 
            viewportHeight: 1334, // 视窗的高度，根据750设备的宽度来指定，一般指定1334，也可以不配置 
            unitPrecision: 3, // 指定`px`转换为视窗单位值的小数位数（很多时候无法整除） 
            viewportUnit: 'vw', // 指定需要转换成的视窗单位，建议使用vw 
            selectorBlackList: ['.ignore', '.hairlines'], // 指定不转换为视窗单位的类，可以自定义，可以无限添加,建议定义一至两个通用的类名 
            minPixelValue: 1, // 小于或等于`1px`不转换为视窗单位，你也可以设置为你想要的值 
            mediaQuery: false // 允许在媒体查询中转换`px` 
        }

        实际的使用效果

        .test { 
            border: .5px solid black; 
            border-bottom-width: 4px; 
            font-size: 14px; 
            line-height: 20px; 
            position: relative; 
            } 
        [w-188-246] {
             width: 188px; 
             }

        编译结果

        .test { 
            border: .5px solid #000; 
            border-bottom-width: .533vw; 
            font-size: 1.867vw; 
            line-height: 2.667vw; 
            position: relative; 
        } 
        [w-188-246] { 
            width: 25.067vw; 
        }

        ## 在不想要把px转换为vw的时候，首先在对应的元素（html）中添加配置中指定的类名.ignore或.hairlines( .hairlines一般用于设置border-width:0.5px的元素中)
        ## 使用范围
            容器适配，可以使用vw
            文本的适配，可以使用vw
            大于1px的边框、圆角、阴影都可以使用vw
            内距和外距，可以使用vw


## postcss-aspect-ratio-mini 处理元素容器宽高比。

        **有一点需要特别注意：aspect-ratio属性不能和其他属性写在一起，否则编译出来的属性只会留下aspect-ratio的值

        //编译前
        [w-188-246] { width: 188px; background-color: red; aspect-ratio: '188:246'; }
        //编译后
        [w-188-246]:before { padding-top: 130.85106382978725%; }

        因此必须将css的样式分开写

        [w-188-246] { width: 188px; background-color: red; }

        [w-188-246] { aspect-ratio: '188:246'; }
        