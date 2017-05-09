module util.meta;

import std.traits;
import std.meta;

template ReturnTypes(Args...){
    alias ReturnTypes = staticMap!(ReturnType, Args);
};

template WithoutNull(Args...){
    alias WithoutNull = EraseAll!(typeof(null), Args);
};

template AllConversions(Args...){
    alias AllConversions = WithoutNull!(NoDuplicates!(staticMap!(ImplicitConversionTargets, Args)));
};

template GreatestCommonType(Args...){
    static if(is(CommonType!Args == void)){
        alias temp = DerivedToFront!(Reverse!(AllConversions!(Args)));
    }else{
        alias temp = AliasSeq!(CommonType!(Args));
    }
    static if(temp.length){
        alias GreatestCommonType = temp[0];
    }else{
        alias GreatestCommonType = void;
    }
};
