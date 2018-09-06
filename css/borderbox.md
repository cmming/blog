### 合并bootstrap 时，注意bootstrap 采用的盒模型为 border-box

    ```
        // Box sizing
        @mixin box-sizing($boxmodel) {
        -webkit-box-sizing: $boxmodel;
            -moz-box-sizing: $boxmodel;
                box-sizing: $boxmodel;
        }

        * {
            @include box-sizing(border-box);
        }
        *:before,
        *:after {
            @include box-sizing(border-box);
        }


    ```

所有再以后项目中使用不同 ui组件的时候要注意 盒模型类型是否相同




### border-box 好处

    减少子元素出现宽度溢出的可能；content-box 会让中 元素宽度不包含border和padding ，100%宽度加上一些padding和border 就会让子元素宽度溢出