## 编写支持数据双向绑定的通用组件

    1. 父组件向子组件传递参数 :attr=attrData

    2.子组件向父组件传递参数 （试用事件的方式向父组件传递改变的参数） 



### 子组件 

    1.使用事件回掉，返回数据，方便父组件数据双向绑定
    2.子组件不能直接改变父组件传过来的值，必须使用一个data 值进行中继，否则会出现错误警告。

```
子组件
html

<template>
    <div class="modal">
        {{dataValue}}
        <div class="close" @click="cancel">X</div>
    </div>
</template>




js


<script>
export default {
  props: {
    cmvalue: {
      type: Boolean,
      default: false
    }
  },
  data() {
    return { dataValue: "" };
  },

  watch: {
    cmvalue(val) {
      console.log(val);
      this.dataValue = val;
    },
    dataValue(val) {
      this.$emit("cmchange", val);
    }
  },
  methods: {
    cancel() {
      this.dataValue = !this.dataValue;
    }
  },
  //第一次加载组件时候
  mounted() {
    this.dataValue = this.cmvalue;
  }
};
</script>

```


父组件调用

```
<no-sync :cmvalue="noSyncData" @cmchange="cmChange1"></no-sync>


js
<script>
import noSync from "@/components/Demo/noSync";
export default {
  components: { noSync },
  data() {
    return {
      noSyncData: true,
      inputData: "12"
    };
  },
  methods: {
    changeNoSync() {
      this.noSyncData = !this.noSyncData;
    },
    cmChange1(val) {
      this.noSyncData = val;
    }
  }
};
</script>

```


## 总结 

    子组件不能直接改变父组件的数据，父组件的数据是否改变，取决于自己的子组件回掉事件中的回掉参数，是否重新赋值给父组件