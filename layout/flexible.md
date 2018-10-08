### 移动端值布局 之flex  rem

####//解决 不同 dpr 设备的字体不同  在线地址 https://jsfiddle.net/chmi93/3wropLbe/1/
    @mixin font-dpr($font-size){
        font-size: $font-size;

        [data-dpr="2"] & {
            font-size: $font-size * 2;
        }

        [data-dpr="3"] & {
            font-size: $font-size * 3;
        }
    }

    @include font-dpr(16px); 
    @include font-dpr(1rem); //文本字号不建议使用rem


#### //解决 px 转换为 rem
    @function px2em($px, $base-font-size: 16px) {
        @if (unitless($px)) {
            @warn "Assuming #{$px} to be in pixels, attempting to convert it into pixels for you";
            @return px2em($px + 0px); // That may fail.
        } @else if (unit($px) == em) {
            @return $px;
        }
        @return ($px / $base-font-size) * 1em;
    }


    @mixin px2rem($property,$px-values,$baseline-px:16px,$support-for-ie:false){
        //Conver the baseline into rems
        $baseline-rem: $baseline-px / 1rem * 1;
        //Print the first line in pixel values
        @if $support-for-ie {
            #{$property}: $px-values;
        }
        //if there is only one (numeric) value, return the property/value line for it.
        @if type-of($px-values) == "number"{
            #{$property}: $px-values / $baseline-rem;
        }
        @else {
            //Create an empty list that we can dump values into
            $rem-values:();
            @each $value in $px-values{
                // If the value is zero or not a number, return it
                @if $value == 0 or type-of($value) != "number"{
                    $rem-values: append($rem-values, $value / $baseline-rem);
                }
            }
            // Return the property and its list of converted values
            #{$property}: $rem-values;
        }
    }

#### //编辑器也可以使用 插件自动转换(cssrem)

#### vue 中最简单的做法，直接使用别人写好的插件自动转换

    postcss-px2rem （同时解决上面的px转化为rem的计算和以及不同dpr设备下字体的转化）

    https://github.com/songsiqi/px2rem-postcss






