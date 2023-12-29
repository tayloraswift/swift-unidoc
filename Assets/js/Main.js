/*! For license information please see Main.js.LICENSE.txt */
(()=>{var e={336:(e,t,r)=>{var n,i;!function(){var s,o,a,u,l,c,d,h,p,f,m,y,g,x,v,w,k,Q,E,b,L,S,T,P,I,O,R,C,F,N,A=function(e){var t=new A.Builder;return t.pipeline.add(A.trimmer,A.stopWordFilter,A.stemmer),t.searchPipeline.add(A.stemmer),e.call(t,t),t.build()};A.version="2.3.9",A.utils={},A.utils.warn=(s=this,function(e){s.console&&console.warn&&console.warn(e)}),A.utils.asString=function(e){return null==e?"":e.toString()},A.utils.clone=function(e){if(null==e)return e;for(var t=Object.create(null),r=Object.keys(e),n=0;n<r.length;n++){var i=r[n],s=e[i];if(Array.isArray(s))t[i]=s.slice();else{if("string"!=typeof s&&"number"!=typeof s&&"boolean"!=typeof s)throw new TypeError("clone is not deep and does not support nested objects");t[i]=s}}return t},A.FieldRef=function(e,t,r){this.docRef=e,this.fieldName=t,this._stringValue=r},A.FieldRef.joiner="/",A.FieldRef.fromString=function(e){var t=e.indexOf(A.FieldRef.joiner);if(-1===t)throw"malformed field ref string";var r=e.slice(0,t),n=e.slice(t+1);return new A.FieldRef(n,r,e)},A.FieldRef.prototype.toString=function(){return null==this._stringValue&&(this._stringValue=this.fieldName+A.FieldRef.joiner+this.docRef),this._stringValue},A.Set=function(e){if(this.elements=Object.create(null),e){this.length=e.length;for(var t=0;t<this.length;t++)this.elements[e[t]]=!0}else this.length=0},A.Set.complete={intersect:function(e){return e},union:function(){return this},contains:function(){return!0}},A.Set.empty={intersect:function(){return this},union:function(e){return e},contains:function(){return!1}},A.Set.prototype.contains=function(e){return!!this.elements[e]},A.Set.prototype.intersect=function(e){var t,r,n,i=[];if(e===A.Set.complete)return this;if(e===A.Set.empty)return e;this.length<e.length?(t=this,r=e):(t=e,r=this),n=Object.keys(t.elements);for(var s=0;s<n.length;s++){var o=n[s];o in r.elements&&i.push(o)}return new A.Set(i)},A.Set.prototype.union=function(e){return e===A.Set.complete?A.Set.complete:e===A.Set.empty?this:new A.Set(Object.keys(this.elements).concat(Object.keys(e.elements)))},A.idf=function(e,t){var r=0;for(var n in e)"_index"!=n&&(r+=Object.keys(e[n]).length);var i=(t-r+.5)/(r+.5);return Math.log(1+Math.abs(i))},A.Token=function(e,t){this.str=e||"",this.metadata=t||{}},A.Token.prototype.toString=function(){return this.str},A.Token.prototype.update=function(e){return this.str=e(this.str,this.metadata),this},A.Token.prototype.clone=function(e){return e=e||function(e){return e},new A.Token(e(this.str,this.metadata),this.metadata)},A.tokenizer=function(e,t){if(null==e||null==e)return[];if(Array.isArray(e))return e.map((function(e){return new A.Token(A.utils.asString(e).toLowerCase(),A.utils.clone(t))}));for(var r=e.toString().toLowerCase(),n=r.length,i=[],s=0,o=0;s<=n;s++){var a=s-o;if(r.charAt(s).match(A.tokenizer.separator)||s==n){if(a>0){var u=A.utils.clone(t)||{};u.position=[o,a],u.index=i.length,i.push(new A.Token(r.slice(o,s),u))}o=s+1}}return i},A.tokenizer.separator=/[\s\-]+/,A.Pipeline=function(){this._stack=[]},A.Pipeline.registeredFunctions=Object.create(null),A.Pipeline.registerFunction=function(e,t){t in this.registeredFunctions&&A.utils.warn("Overwriting existing registered function: "+t),e.label=t,A.Pipeline.registeredFunctions[e.label]=e},A.Pipeline.warnIfFunctionNotRegistered=function(e){e.label&&e.label in this.registeredFunctions||A.utils.warn("Function is not registered with pipeline. This may cause problems when serialising the index.\n",e)},A.Pipeline.load=function(e){var t=new A.Pipeline;return e.forEach((function(e){var r=A.Pipeline.registeredFunctions[e];if(!r)throw new Error("Cannot load unregistered function: "+e);t.add(r)})),t},A.Pipeline.prototype.add=function(){Array.prototype.slice.call(arguments).forEach((function(e){A.Pipeline.warnIfFunctionNotRegistered(e),this._stack.push(e)}),this)},A.Pipeline.prototype.after=function(e,t){A.Pipeline.warnIfFunctionNotRegistered(t);var r=this._stack.indexOf(e);if(-1==r)throw new Error("Cannot find existingFn");r+=1,this._stack.splice(r,0,t)},A.Pipeline.prototype.before=function(e,t){A.Pipeline.warnIfFunctionNotRegistered(t);var r=this._stack.indexOf(e);if(-1==r)throw new Error("Cannot find existingFn");this._stack.splice(r,0,t)},A.Pipeline.prototype.remove=function(e){var t=this._stack.indexOf(e);-1!=t&&this._stack.splice(t,1)},A.Pipeline.prototype.run=function(e){for(var t=this._stack.length,r=0;r<t;r++){for(var n=this._stack[r],i=[],s=0;s<e.length;s++){var o=n(e[s],s,e);if(null!=o&&""!==o)if(Array.isArray(o))for(var a=0;a<o.length;a++)i.push(o[a]);else i.push(o)}e=i}return e},A.Pipeline.prototype.runString=function(e,t){var r=new A.Token(e,t);return this.run([r]).map((function(e){return e.toString()}))},A.Pipeline.prototype.reset=function(){this._stack=[]},A.Pipeline.prototype.toJSON=function(){return this._stack.map((function(e){return A.Pipeline.warnIfFunctionNotRegistered(e),e.label}))},A.Vector=function(e){this._magnitude=0,this.elements=e||[]},A.Vector.prototype.positionForIndex=function(e){if(0==this.elements.length)return 0;for(var t=0,r=this.elements.length/2,n=r-t,i=Math.floor(n/2),s=this.elements[2*i];n>1&&(s<e&&(t=i),s>e&&(r=i),s!=e);)n=r-t,i=t+Math.floor(n/2),s=this.elements[2*i];return s==e||s>e?2*i:s<e?2*(i+1):void 0},A.Vector.prototype.insert=function(e,t){this.upsert(e,t,(function(){throw"duplicate index"}))},A.Vector.prototype.upsert=function(e,t,r){this._magnitude=0;var n=this.positionForIndex(e);this.elements[n]==e?this.elements[n+1]=r(this.elements[n+1],t):this.elements.splice(n,0,e,t)},A.Vector.prototype.magnitude=function(){if(this._magnitude)return this._magnitude;for(var e=0,t=this.elements.length,r=1;r<t;r+=2){var n=this.elements[r];e+=n*n}return this._magnitude=Math.sqrt(e)},A.Vector.prototype.dot=function(e){for(var t=0,r=this.elements,n=e.elements,i=r.length,s=n.length,o=0,a=0,u=0,l=0;u<i&&l<s;)(o=r[u])<(a=n[l])?u+=2:o>a?l+=2:o==a&&(t+=r[u+1]*n[l+1],u+=2,l+=2);return t},A.Vector.prototype.similarity=function(e){return this.dot(e)/this.magnitude()||0},A.Vector.prototype.toArray=function(){for(var e=new Array(this.elements.length/2),t=1,r=0;t<this.elements.length;t+=2,r++)e[r]=this.elements[t];return e},A.Vector.prototype.toJSON=function(){return this.elements},A.stemmer=(o={ational:"ate",tional:"tion",enci:"ence",anci:"ance",izer:"ize",bli:"ble",alli:"al",entli:"ent",eli:"e",ousli:"ous",ization:"ize",ation:"ate",ator:"ate",alism:"al",iveness:"ive",fulness:"ful",ousness:"ous",aliti:"al",iviti:"ive",biliti:"ble",logi:"log"},a={icate:"ic",ative:"",alize:"al",iciti:"ic",ical:"ic",ful:"",ness:""},d="^("+(l="[^aeiou][^aeiouy]*")+")?"+(c=(u="[aeiouy]")+"[aeiou]*")+l+"("+c+")?$",h="^("+l+")?"+c+l+c+l,p="^("+l+")?"+u,f=new RegExp("^("+l+")?"+c+l),m=new RegExp(h),y=new RegExp(d),g=new RegExp(p),x=/^(.+?)(ss|i)es$/,v=/^(.+?)([^s])s$/,w=/^(.+?)eed$/,k=/^(.+?)(ed|ing)$/,Q=/.$/,E=/(at|bl|iz)$/,b=new RegExp("([^aeiouylsz])\\1$"),L=new RegExp("^"+l+u+"[^aeiouwxy]$"),S=/^(.+?[^aeiou])y$/,T=/^(.+?)(ational|tional|enci|anci|izer|bli|alli|entli|eli|ousli|ization|ation|ator|alism|iveness|fulness|ousness|aliti|iviti|biliti|logi)$/,P=/^(.+?)(icate|ative|alize|iciti|ical|ful|ness)$/,I=/^(.+?)(al|ance|ence|er|ic|able|ible|ant|ement|ment|ent|ou|ism|ate|iti|ous|ive|ize)$/,O=/^(.+?)(s|t)(ion)$/,R=/^(.+?)e$/,C=/ll$/,F=new RegExp("^"+l+u+"[^aeiouwxy]$"),N=function(e){var t,r,n,i,s,u,l;if(e.length<3)return e;if("y"==(n=e.substr(0,1))&&(e=n.toUpperCase()+e.substr(1)),s=v,(i=x).test(e)?e=e.replace(i,"$1$2"):s.test(e)&&(e=e.replace(s,"$1$2")),s=k,(i=w).test(e)){var c=i.exec(e);(i=f).test(c[1])&&(i=Q,e=e.replace(i,""))}else s.test(e)&&(t=(c=s.exec(e))[1],(s=g).test(t)&&(u=b,l=L,(s=E).test(e=t)?e+="e":u.test(e)?(i=Q,e=e.replace(i,"")):l.test(e)&&(e+="e")));return(i=S).test(e)&&(e=(t=(c=i.exec(e))[1])+"i"),(i=T).test(e)&&(t=(c=i.exec(e))[1],r=c[2],(i=f).test(t)&&(e=t+o[r])),(i=P).test(e)&&(t=(c=i.exec(e))[1],r=c[2],(i=f).test(t)&&(e=t+a[r])),s=O,(i=I).test(e)?(t=(c=i.exec(e))[1],(i=m).test(t)&&(e=t)):s.test(e)&&(t=(c=s.exec(e))[1]+c[2],(s=m).test(t)&&(e=t)),(i=R).test(e)&&(t=(c=i.exec(e))[1],s=y,u=F,((i=m).test(t)||s.test(t)&&!u.test(t))&&(e=t)),s=m,(i=C).test(e)&&s.test(e)&&(i=Q,e=e.replace(i,"")),"y"==n&&(e=n.toLowerCase()+e.substr(1)),e},function(e){return e.update(N)}),A.Pipeline.registerFunction(A.stemmer,"stemmer"),A.generateStopWordFilter=function(e){var t=e.reduce((function(e,t){return e[t]=t,e}),{});return function(e){if(e&&t[e.toString()]!==e.toString())return e}},A.stopWordFilter=A.generateStopWordFilter(["a","able","about","across","after","all","almost","also","am","among","an","and","any","are","as","at","be","because","been","but","by","can","cannot","could","dear","did","do","does","either","else","ever","every","for","from","get","got","had","has","have","he","her","hers","him","his","how","however","i","if","in","into","is","it","its","just","least","let","like","likely","may","me","might","most","must","my","neither","no","nor","not","of","off","often","on","only","or","other","our","own","rather","said","say","says","she","should","since","so","some","than","that","the","their","them","then","there","these","they","this","tis","to","too","twas","us","wants","was","we","were","what","when","where","which","while","who","whom","why","will","with","would","yet","you","your"]),A.Pipeline.registerFunction(A.stopWordFilter,"stopWordFilter"),A.trimmer=function(e){return e.update((function(e){return e.replace(/^\W+/,"").replace(/\W+$/,"")}))},A.Pipeline.registerFunction(A.trimmer,"trimmer"),A.TokenSet=function(){this.final=!1,this.edges={},this.id=A.TokenSet._nextId,A.TokenSet._nextId+=1},A.TokenSet._nextId=1,A.TokenSet.fromArray=function(e){for(var t=new A.TokenSet.Builder,r=0,n=e.length;r<n;r++)t.insert(e[r]);return t.finish(),t.root},A.TokenSet.fromClause=function(e){return"editDistance"in e?A.TokenSet.fromFuzzyString(e.term,e.editDistance):A.TokenSet.fromString(e.term)},A.TokenSet.fromFuzzyString=function(e,t){for(var r=new A.TokenSet,n=[{node:r,editsRemaining:t,str:e}];n.length;){var i=n.pop();if(i.str.length>0){var s,o=i.str.charAt(0);o in i.node.edges?s=i.node.edges[o]:(s=new A.TokenSet,i.node.edges[o]=s),1==i.str.length&&(s.final=!0),n.push({node:s,editsRemaining:i.editsRemaining,str:i.str.slice(1)})}if(0!=i.editsRemaining){if("*"in i.node.edges)var a=i.node.edges["*"];else a=new A.TokenSet,i.node.edges["*"]=a;if(0==i.str.length&&(a.final=!0),n.push({node:a,editsRemaining:i.editsRemaining-1,str:i.str}),i.str.length>1&&n.push({node:i.node,editsRemaining:i.editsRemaining-1,str:i.str.slice(1)}),1==i.str.length&&(i.node.final=!0),i.str.length>=1){if("*"in i.node.edges)var u=i.node.edges["*"];else u=new A.TokenSet,i.node.edges["*"]=u;1==i.str.length&&(u.final=!0),n.push({node:u,editsRemaining:i.editsRemaining-1,str:i.str.slice(1)})}if(i.str.length>1){var l,c=i.str.charAt(0),d=i.str.charAt(1);d in i.node.edges?l=i.node.edges[d]:(l=new A.TokenSet,i.node.edges[d]=l),1==i.str.length&&(l.final=!0),n.push({node:l,editsRemaining:i.editsRemaining-1,str:c+i.str.slice(2)})}}}return r},A.TokenSet.fromString=function(e){for(var t=new A.TokenSet,r=t,n=0,i=e.length;n<i;n++){var s=e[n],o=n==i-1;if("*"==s)t.edges[s]=t,t.final=o;else{var a=new A.TokenSet;a.final=o,t.edges[s]=a,t=a}}return r},A.TokenSet.prototype.toArray=function(){for(var e=[],t=[{prefix:"",node:this}];t.length;){var r=t.pop(),n=Object.keys(r.node.edges),i=n.length;r.node.final&&(r.prefix.charAt(0),e.push(r.prefix));for(var s=0;s<i;s++){var o=n[s];t.push({prefix:r.prefix.concat(o),node:r.node.edges[o]})}}return e},A.TokenSet.prototype.toString=function(){if(this._str)return this._str;for(var e=this.final?"1":"0",t=Object.keys(this.edges).sort(),r=t.length,n=0;n<r;n++){var i=t[n];e=e+i+this.edges[i].id}return e},A.TokenSet.prototype.intersect=function(e){for(var t=new A.TokenSet,r=void 0,n=[{qNode:e,output:t,node:this}];n.length;){r=n.pop();for(var i=Object.keys(r.qNode.edges),s=i.length,o=Object.keys(r.node.edges),a=o.length,u=0;u<s;u++)for(var l=i[u],c=0;c<a;c++){var d=o[c];if(d==l||"*"==l){var h=r.node.edges[d],p=r.qNode.edges[l],f=h.final&&p.final,m=void 0;d in r.output.edges?(m=r.output.edges[d]).final=m.final||f:((m=new A.TokenSet).final=f,r.output.edges[d]=m),n.push({qNode:p,output:m,node:h})}}}return t},A.TokenSet.Builder=function(){this.previousWord="",this.root=new A.TokenSet,this.uncheckedNodes=[],this.minimizedNodes={}},A.TokenSet.Builder.prototype.insert=function(e){var t,r=0;if(e<this.previousWord)throw new Error("Out of order word insertion");for(var n=0;n<e.length&&n<this.previousWord.length&&e[n]==this.previousWord[n];n++)r++;for(this.minimize(r),t=0==this.uncheckedNodes.length?this.root:this.uncheckedNodes[this.uncheckedNodes.length-1].child,n=r;n<e.length;n++){var i=new A.TokenSet,s=e[n];t.edges[s]=i,this.uncheckedNodes.push({parent:t,char:s,child:i}),t=i}t.final=!0,this.previousWord=e},A.TokenSet.Builder.prototype.finish=function(){this.minimize(0)},A.TokenSet.Builder.prototype.minimize=function(e){for(var t=this.uncheckedNodes.length-1;t>=e;t--){var r=this.uncheckedNodes[t],n=r.child.toString();n in this.minimizedNodes?r.parent.edges[r.char]=this.minimizedNodes[n]:(r.child._str=n,this.minimizedNodes[n]=r.child),this.uncheckedNodes.pop()}},A.Index=function(e){this.invertedIndex=e.invertedIndex,this.fieldVectors=e.fieldVectors,this.tokenSet=e.tokenSet,this.fields=e.fields,this.pipeline=e.pipeline},A.Index.prototype.search=function(e){return this.query((function(t){new A.QueryParser(e,t).parse()}))},A.Index.prototype.query=function(e){for(var t=new A.Query(this.fields),r=Object.create(null),n=Object.create(null),i=Object.create(null),s=Object.create(null),o=Object.create(null),a=0;a<this.fields.length;a++)n[this.fields[a]]=new A.Vector;for(e.call(t,t),a=0;a<t.clauses.length;a++){var u,l=t.clauses[a],c=A.Set.empty;u=l.usePipeline?this.pipeline.runString(l.term,{fields:l.fields}):[l.term];for(var d=0;d<u.length;d++){var h=u[d];l.term=h;var p=A.TokenSet.fromClause(l),f=this.tokenSet.intersect(p).toArray();if(0===f.length&&l.presence===A.Query.presence.REQUIRED){for(var m=0;m<l.fields.length;m++)s[R=l.fields[m]]=A.Set.empty;break}for(var y=0;y<f.length;y++){var g=f[y],x=this.invertedIndex[g],v=x._index;for(m=0;m<l.fields.length;m++){var w=x[R=l.fields[m]],k=Object.keys(w),Q=g+"/"+R,E=new A.Set(k);if(l.presence==A.Query.presence.REQUIRED&&(c=c.union(E),void 0===s[R]&&(s[R]=A.Set.complete)),l.presence!=A.Query.presence.PROHIBITED){if(n[R].upsert(v,l.boost,(function(e,t){return e+t})),!i[Q]){for(var b=0;b<k.length;b++){var L,S=k[b],T=new A.FieldRef(S,R),P=w[S];void 0===(L=r[T])?r[T]=new A.MatchData(g,R,P):L.add(g,R,P)}i[Q]=!0}}else void 0===o[R]&&(o[R]=A.Set.empty),o[R]=o[R].union(E)}}}if(l.presence===A.Query.presence.REQUIRED)for(m=0;m<l.fields.length;m++)s[R=l.fields[m]]=s[R].intersect(c)}var I=A.Set.complete,O=A.Set.empty;for(a=0;a<this.fields.length;a++){var R;s[R=this.fields[a]]&&(I=I.intersect(s[R])),o[R]&&(O=O.union(o[R]))}var C=Object.keys(r),F=[],N=Object.create(null);if(t.isNegated())for(C=Object.keys(this.fieldVectors),a=0;a<C.length;a++){T=C[a];var j=A.FieldRef.fromString(T);r[T]=new A.MatchData}for(a=0;a<C.length;a++){var D=(j=A.FieldRef.fromString(C[a])).docRef;if(I.contains(D)&&!O.contains(D)){var _,B=this.fieldVectors[j],z=n[j.fieldName].similarity(B);if(void 0!==(_=N[D]))_.score+=z,_.matchData.combine(r[j]);else{var V={ref:D,score:z,matchData:r[j]};N[D]=V,F.push(V)}}}return F.sort((function(e,t){return t.score-e.score}))},A.Index.prototype.toJSON=function(){var e=Object.keys(this.invertedIndex).sort().map((function(e){return[e,this.invertedIndex[e]]}),this),t=Object.keys(this.fieldVectors).map((function(e){return[e,this.fieldVectors[e].toJSON()]}),this);return{version:A.version,fields:this.fields,fieldVectors:t,invertedIndex:e,pipeline:this.pipeline.toJSON()}},A.Index.load=function(e){var t={},r={},n=e.fieldVectors,i=Object.create(null),s=e.invertedIndex,o=new A.TokenSet.Builder,a=A.Pipeline.load(e.pipeline);e.version!=A.version&&A.utils.warn("Version mismatch when loading serialised index. Current version of lunr '"+A.version+"' does not match serialized index '"+e.version+"'");for(var u=0;u<n.length;u++){var l=(d=n[u])[0],c=d[1];r[l]=new A.Vector(c)}for(u=0;u<s.length;u++){var d,h=(d=s[u])[0],p=d[1];o.insert(h),i[h]=p}return o.finish(),t.fields=e.fields,t.fieldVectors=r,t.invertedIndex=i,t.tokenSet=o.root,t.pipeline=a,new A.Index(t)},A.Builder=function(){this._ref="id",this._fields=Object.create(null),this._documents=Object.create(null),this.invertedIndex=Object.create(null),this.fieldTermFrequencies={},this.fieldLengths={},this.tokenizer=A.tokenizer,this.pipeline=new A.Pipeline,this.searchPipeline=new A.Pipeline,this.documentCount=0,this._b=.75,this._k1=1.2,this.termIndex=0,this.metadataWhitelist=[]},A.Builder.prototype.ref=function(e){this._ref=e},A.Builder.prototype.field=function(e,t){if(/\//.test(e))throw new RangeError("Field '"+e+"' contains illegal character '/'");this._fields[e]=t||{}},A.Builder.prototype.b=function(e){this._b=e<0?0:e>1?1:e},A.Builder.prototype.k1=function(e){this._k1=e},A.Builder.prototype.add=function(e,t){var r=e[this._ref],n=Object.keys(this._fields);this._documents[r]=t||{},this.documentCount+=1;for(var i=0;i<n.length;i++){var s=n[i],o=this._fields[s].extractor,a=o?o(e):e[s],u=this.tokenizer(a,{fields:[s]}),l=this.pipeline.run(u),c=new A.FieldRef(r,s),d=Object.create(null);this.fieldTermFrequencies[c]=d,this.fieldLengths[c]=0,this.fieldLengths[c]+=l.length;for(var h=0;h<l.length;h++){var p=l[h];if(null==d[p]&&(d[p]=0),d[p]+=1,null==this.invertedIndex[p]){var f=Object.create(null);f._index=this.termIndex,this.termIndex+=1;for(var m=0;m<n.length;m++)f[n[m]]=Object.create(null);this.invertedIndex[p]=f}null==this.invertedIndex[p][s][r]&&(this.invertedIndex[p][s][r]=Object.create(null));for(var y=0;y<this.metadataWhitelist.length;y++){var g=this.metadataWhitelist[y],x=p.metadata[g];null==this.invertedIndex[p][s][r][g]&&(this.invertedIndex[p][s][r][g]=[]),this.invertedIndex[p][s][r][g].push(x)}}}},A.Builder.prototype.calculateAverageFieldLengths=function(){for(var e=Object.keys(this.fieldLengths),t=e.length,r={},n={},i=0;i<t;i++){var s=A.FieldRef.fromString(e[i]),o=s.fieldName;n[o]||(n[o]=0),n[o]+=1,r[o]||(r[o]=0),r[o]+=this.fieldLengths[s]}var a=Object.keys(this._fields);for(i=0;i<a.length;i++){var u=a[i];r[u]=r[u]/n[u]}this.averageFieldLength=r},A.Builder.prototype.createFieldVectors=function(){for(var e={},t=Object.keys(this.fieldTermFrequencies),r=t.length,n=Object.create(null),i=0;i<r;i++){for(var s=A.FieldRef.fromString(t[i]),o=s.fieldName,a=this.fieldLengths[s],u=new A.Vector,l=this.fieldTermFrequencies[s],c=Object.keys(l),d=c.length,h=this._fields[o].boost||1,p=this._documents[s.docRef].boost||1,f=0;f<d;f++){var m,y,g,x=c[f],v=l[x],w=this.invertedIndex[x]._index;void 0===n[x]?(m=A.idf(this.invertedIndex[x],this.documentCount),n[x]=m):m=n[x],y=m*((this._k1+1)*v)/(this._k1*(1-this._b+this._b*(a/this.averageFieldLength[o]))+v),y*=h,y*=p,g=Math.round(1e3*y)/1e3,u.insert(w,g)}e[s]=u}this.fieldVectors=e},A.Builder.prototype.createTokenSet=function(){this.tokenSet=A.TokenSet.fromArray(Object.keys(this.invertedIndex).sort())},A.Builder.prototype.build=function(){return this.calculateAverageFieldLengths(),this.createFieldVectors(),this.createTokenSet(),new A.Index({invertedIndex:this.invertedIndex,fieldVectors:this.fieldVectors,tokenSet:this.tokenSet,fields:Object.keys(this._fields),pipeline:this.searchPipeline})},A.Builder.prototype.use=function(e){var t=Array.prototype.slice.call(arguments,1);t.unshift(this),e.apply(this,t)},A.MatchData=function(e,t,r){for(var n=Object.create(null),i=Object.keys(r||{}),s=0;s<i.length;s++){var o=i[s];n[o]=r[o].slice()}this.metadata=Object.create(null),void 0!==e&&(this.metadata[e]=Object.create(null),this.metadata[e][t]=n)},A.MatchData.prototype.combine=function(e){for(var t=Object.keys(e.metadata),r=0;r<t.length;r++){var n=t[r],i=Object.keys(e.metadata[n]);null==this.metadata[n]&&(this.metadata[n]=Object.create(null));for(var s=0;s<i.length;s++){var o=i[s],a=Object.keys(e.metadata[n][o]);null==this.metadata[n][o]&&(this.metadata[n][o]=Object.create(null));for(var u=0;u<a.length;u++){var l=a[u];null==this.metadata[n][o][l]?this.metadata[n][o][l]=e.metadata[n][o][l]:this.metadata[n][o][l]=this.metadata[n][o][l].concat(e.metadata[n][o][l])}}}},A.MatchData.prototype.add=function(e,t,r){if(!(e in this.metadata))return this.metadata[e]=Object.create(null),void(this.metadata[e][t]=r);if(t in this.metadata[e])for(var n=Object.keys(r),i=0;i<n.length;i++){var s=n[i];s in this.metadata[e][t]?this.metadata[e][t][s]=this.metadata[e][t][s].concat(r[s]):this.metadata[e][t][s]=r[s]}else this.metadata[e][t]=r},A.Query=function(e){this.clauses=[],this.allFields=e},A.Query.wildcard=new String("*"),A.Query.wildcard.NONE=0,A.Query.wildcard.LEADING=1,A.Query.wildcard.TRAILING=2,A.Query.presence={OPTIONAL:1,REQUIRED:2,PROHIBITED:3},A.Query.prototype.clause=function(e){return"fields"in e||(e.fields=this.allFields),"boost"in e||(e.boost=1),"usePipeline"in e||(e.usePipeline=!0),"wildcard"in e||(e.wildcard=A.Query.wildcard.NONE),e.wildcard&A.Query.wildcard.LEADING&&e.term.charAt(0)!=A.Query.wildcard&&(e.term="*"+e.term),e.wildcard&A.Query.wildcard.TRAILING&&e.term.slice(-1)!=A.Query.wildcard&&(e.term=e.term+"*"),"presence"in e||(e.presence=A.Query.presence.OPTIONAL),this.clauses.push(e),this},A.Query.prototype.isNegated=function(){for(var e=0;e<this.clauses.length;e++)if(this.clauses[e].presence!=A.Query.presence.PROHIBITED)return!1;return!0},A.Query.prototype.term=function(e,t){if(Array.isArray(e))return e.forEach((function(e){this.term(e,A.utils.clone(t))}),this),this;var r=t||{};return r.term=e.toString(),this.clause(r),this},A.QueryParseError=function(e,t,r){this.name="QueryParseError",this.message=e,this.start=t,this.end=r},A.QueryParseError.prototype=new Error,A.QueryLexer=function(e){this.lexemes=[],this.str=e,this.length=e.length,this.pos=0,this.start=0,this.escapeCharPositions=[]},A.QueryLexer.prototype.run=function(){for(var e=A.QueryLexer.lexText;e;)e=e(this)},A.QueryLexer.prototype.sliceString=function(){for(var e=[],t=this.start,r=this.pos,n=0;n<this.escapeCharPositions.length;n++)r=this.escapeCharPositions[n],e.push(this.str.slice(t,r)),t=r+1;return e.push(this.str.slice(t,this.pos)),this.escapeCharPositions.length=0,e.join("")},A.QueryLexer.prototype.emit=function(e){this.lexemes.push({type:e,str:this.sliceString(),start:this.start,end:this.pos}),this.start=this.pos},A.QueryLexer.prototype.escapeCharacter=function(){this.escapeCharPositions.push(this.pos-1),this.pos+=1},A.QueryLexer.prototype.next=function(){if(this.pos>=this.length)return A.QueryLexer.EOS;var e=this.str.charAt(this.pos);return this.pos+=1,e},A.QueryLexer.prototype.width=function(){return this.pos-this.start},A.QueryLexer.prototype.ignore=function(){this.start==this.pos&&(this.pos+=1),this.start=this.pos},A.QueryLexer.prototype.backup=function(){this.pos-=1},A.QueryLexer.prototype.acceptDigitRun=function(){var e,t;do{t=(e=this.next()).charCodeAt(0)}while(t>47&&t<58);e!=A.QueryLexer.EOS&&this.backup()},A.QueryLexer.prototype.more=function(){return this.pos<this.length},A.QueryLexer.EOS="EOS",A.QueryLexer.FIELD="FIELD",A.QueryLexer.TERM="TERM",A.QueryLexer.EDIT_DISTANCE="EDIT_DISTANCE",A.QueryLexer.BOOST="BOOST",A.QueryLexer.PRESENCE="PRESENCE",A.QueryLexer.lexField=function(e){return e.backup(),e.emit(A.QueryLexer.FIELD),e.ignore(),A.QueryLexer.lexText},A.QueryLexer.lexTerm=function(e){if(e.width()>1&&(e.backup(),e.emit(A.QueryLexer.TERM)),e.ignore(),e.more())return A.QueryLexer.lexText},A.QueryLexer.lexEditDistance=function(e){return e.ignore(),e.acceptDigitRun(),e.emit(A.QueryLexer.EDIT_DISTANCE),A.QueryLexer.lexText},A.QueryLexer.lexBoost=function(e){return e.ignore(),e.acceptDigitRun(),e.emit(A.QueryLexer.BOOST),A.QueryLexer.lexText},A.QueryLexer.lexEOS=function(e){e.width()>0&&e.emit(A.QueryLexer.TERM)},A.QueryLexer.termSeparator=A.tokenizer.separator,A.QueryLexer.lexText=function(e){for(;;){var t=e.next();if(t==A.QueryLexer.EOS)return A.QueryLexer.lexEOS;if(92!=t.charCodeAt(0)){if(":"==t)return A.QueryLexer.lexField;if("~"==t)return e.backup(),e.width()>0&&e.emit(A.QueryLexer.TERM),A.QueryLexer.lexEditDistance;if("^"==t)return e.backup(),e.width()>0&&e.emit(A.QueryLexer.TERM),A.QueryLexer.lexBoost;if("+"==t&&1===e.width())return e.emit(A.QueryLexer.PRESENCE),A.QueryLexer.lexText;if("-"==t&&1===e.width())return e.emit(A.QueryLexer.PRESENCE),A.QueryLexer.lexText;if(t.match(A.QueryLexer.termSeparator))return A.QueryLexer.lexTerm}else e.escapeCharacter()}},A.QueryParser=function(e,t){this.lexer=new A.QueryLexer(e),this.query=t,this.currentClause={},this.lexemeIdx=0},A.QueryParser.prototype.parse=function(){this.lexer.run(),this.lexemes=this.lexer.lexemes;for(var e=A.QueryParser.parseClause;e;)e=e(this);return this.query},A.QueryParser.prototype.peekLexeme=function(){return this.lexemes[this.lexemeIdx]},A.QueryParser.prototype.consumeLexeme=function(){var e=this.peekLexeme();return this.lexemeIdx+=1,e},A.QueryParser.prototype.nextClause=function(){var e=this.currentClause;this.query.clause(e),this.currentClause={}},A.QueryParser.parseClause=function(e){var t=e.peekLexeme();if(null!=t)switch(t.type){case A.QueryLexer.PRESENCE:return A.QueryParser.parsePresence;case A.QueryLexer.FIELD:return A.QueryParser.parseField;case A.QueryLexer.TERM:return A.QueryParser.parseTerm;default:var r="expected either a field or a term, found "+t.type;throw t.str.length>=1&&(r+=" with value '"+t.str+"'"),new A.QueryParseError(r,t.start,t.end)}},A.QueryParser.parsePresence=function(e){var t=e.consumeLexeme();if(null!=t){switch(t.str){case"-":e.currentClause.presence=A.Query.presence.PROHIBITED;break;case"+":e.currentClause.presence=A.Query.presence.REQUIRED;break;default:var r="unrecognised presence operator'"+t.str+"'";throw new A.QueryParseError(r,t.start,t.end)}var n=e.peekLexeme();if(null==n)throw r="expecting term or field, found nothing",new A.QueryParseError(r,t.start,t.end);switch(n.type){case A.QueryLexer.FIELD:return A.QueryParser.parseField;case A.QueryLexer.TERM:return A.QueryParser.parseTerm;default:throw r="expecting term or field, found '"+n.type+"'",new A.QueryParseError(r,n.start,n.end)}}},A.QueryParser.parseField=function(e){var t=e.consumeLexeme();if(null!=t){if(-1==e.query.allFields.indexOf(t.str)){var r=e.query.allFields.map((function(e){return"'"+e+"'"})).join(", "),n="unrecognised field '"+t.str+"', possible fields: "+r;throw new A.QueryParseError(n,t.start,t.end)}e.currentClause.fields=[t.str];var i=e.peekLexeme();if(null==i)throw n="expecting term, found nothing",new A.QueryParseError(n,t.start,t.end);if(i.type===A.QueryLexer.TERM)return A.QueryParser.parseTerm;throw n="expecting term, found '"+i.type+"'",new A.QueryParseError(n,i.start,i.end)}},A.QueryParser.parseTerm=function(e){var t=e.consumeLexeme();if(null!=t){e.currentClause.term=t.str.toLowerCase(),-1!=t.str.indexOf("*")&&(e.currentClause.usePipeline=!1);var r=e.peekLexeme();if(null!=r)switch(r.type){case A.QueryLexer.TERM:return e.nextClause(),A.QueryParser.parseTerm;case A.QueryLexer.FIELD:return e.nextClause(),A.QueryParser.parseField;case A.QueryLexer.EDIT_DISTANCE:return A.QueryParser.parseEditDistance;case A.QueryLexer.BOOST:return A.QueryParser.parseBoost;case A.QueryLexer.PRESENCE:return e.nextClause(),A.QueryParser.parsePresence;default:var n="Unexpected lexeme type '"+r.type+"'";throw new A.QueryParseError(n,r.start,r.end)}else e.nextClause()}},A.QueryParser.parseEditDistance=function(e){var t=e.consumeLexeme();if(null!=t){var r=parseInt(t.str,10);if(isNaN(r)){var n="edit distance must be numeric";throw new A.QueryParseError(n,t.start,t.end)}e.currentClause.editDistance=r;var i=e.peekLexeme();if(null!=i)switch(i.type){case A.QueryLexer.TERM:return e.nextClause(),A.QueryParser.parseTerm;case A.QueryLexer.FIELD:return e.nextClause(),A.QueryParser.parseField;case A.QueryLexer.EDIT_DISTANCE:return A.QueryParser.parseEditDistance;case A.QueryLexer.BOOST:return A.QueryParser.parseBoost;case A.QueryLexer.PRESENCE:return e.nextClause(),A.QueryParser.parsePresence;default:throw n="Unexpected lexeme type '"+i.type+"'",new A.QueryParseError(n,i.start,i.end)}else e.nextClause()}},A.QueryParser.parseBoost=function(e){var t=e.consumeLexeme();if(null!=t){var r=parseInt(t.str,10);if(isNaN(r)){var n="boost must be numeric";throw new A.QueryParseError(n,t.start,t.end)}e.currentClause.boost=r;var i=e.peekLexeme();if(null!=i)switch(i.type){case A.QueryLexer.TERM:return e.nextClause(),A.QueryParser.parseTerm;case A.QueryLexer.FIELD:return e.nextClause(),A.QueryParser.parseField;case A.QueryLexer.EDIT_DISTANCE:return A.QueryParser.parseEditDistance;case A.QueryLexer.BOOST:return A.QueryParser.parseBoost;case A.QueryLexer.PRESENCE:return e.nextClause(),A.QueryParser.parsePresence;default:throw n="Unexpected lexeme type '"+i.type+"'",new A.QueryParseError(n,i.start,i.end)}else e.nextClause()}},void 0===(i="function"==typeof(n=function(){return A})?n.call(t,r,t,e):n)||(e.exports=i)}()}},t={};function r(n){var i=t[n];if(void 0!==i)return i.exports;var s=t[n]={exports:{}};return e[n](s,s.exports,r),s.exports}(()=>{"use strict";var e=r(336);class t{constructor(e){this.index=0,this.choices=e}highlight(e){const t=e.children.item(this.index);t instanceof HTMLElement&&t.classList.add("selected")}rehighlight(e,t){if(t==this.index)return;const r=e.children.item(this.index);r instanceof HTMLElement&&(r.classList.remove("selected"),0==r.classList.length&&r.removeAttribute("class"),this.index=t,this.highlight(e))}}class n{constructor(t){this.symbols=t,this.index=e((function(){this.ref("i"),this.field("mwords"),this.field("pwords"),this.pipeline.remove(e.stemmer),this.searchPipeline.remove(e.stemmer);for(let e=0;e<t.length;e++){const r=t[e];"module"in r?this.add({i:e,mwords:r.keywords}):this.add({i:e,pwords:r.keywords})}}))}search(r,n){if(0===r.length)return null;let i,s=[];for(const e of r.toLowerCase().split(/[\-\s\.]/))e.length>0&&s.push(e);return i=s.length>0?this.index.query((function(t){const r=n?["pwords"]:["mwords","pwords"];for(const n of s)t.term(n,{fields:r,boost:100}),t.term(n,{fields:r,boost:10,wildcard:e.Query.wildcard.TRAILING}),t.term(n,{fields:r,boost:5,wildcard:e.Query.wildcard.TRAILING,editDistance:1}),t.term(n,{fields:r,boost:1,wildcard:e.Query.wildcard.TRAILING,editDistance:2})})):[],i.length>0?new t(i.slice(0,10)):null}}class i{constructor(e){this.loading=!1,this.output=null,this.input=e.input,this.mode=e.mode,this.list=e.list}async reinitialize(){if(console.log("Reinitializing search index"),this.loading||void 0!==this.runner)return;this.loading=!0;let e=[fetch("/lunr/packages.json").then((async function(e){return e.json()}))];for(const t of volumes){const r=host+"/lunr/"+t.id;e.push(fetch(r).then((async function(e){return e.json().then((function(e){return{cultures:e,trunk:t.trunk}}))})))}this.runner=await Promise.all(e).then((function(e){let t=[],r=new Set;for(const e of volumes){const n=e.id.split(":")[0];r.add(n),t.push({dependency:!0,keywords:n.split(/\-/),name:n,uri:e.trunk})}for(const n of e)if(n instanceof Array)for(const e of n)r.has(e)||t.push({dependency:!1,keywords:e.split(/\-/),name:e,uri:"/tags/"+e});else for(const e of n.cultures){const r=e.c;for(const s of e.n){var i=n.trunk+"/";i+=s.s.replace("\t",".").replaceAll(" ","/").toLowerCase();const e=s.s.split(/\s+/);t.push({module:r,keywords:e,display:e.slice(1).join("."),uri:i})}}return new n(t)})).catch((function(e){console.error("error:",e)})),this.loading=!1,this.suggest()}suggest(){if(void 0===this.runner)return;if(this.output=this.runner.search(this.input.value,null!==this.mode&&this.mode.checked),null===this.output)return void this.list.replaceChildren();let e=[];for(const t of this.output.choices){const r=this.runner.symbols[parseInt(t.ref)],n=document.createElement("li"),i=document.createElement("a"),s=document.createElement("span"),o=document.createElement("span");"dependency"in r?(r.dependency?(o.appendChild(document.createTextNode("Package Dependency")),n.classList.add("package","dependency")):(o.appendChild(document.createTextNode("Package")),n.classList.add("package")),s.appendChild(document.createTextNode(r.name))):(o.appendChild(document.createTextNode(r.module)),o.classList.add("module"),s.appendChild(document.createTextNode(r.display))),i.appendChild(s),i.appendChild(o),i.setAttribute("href",r.uri),n.appendChild(i),e.push(n)}this.list.replaceChildren(...e),this.output.highlight(this.list)}navigate(e){if(null!==this.output)switch(e.key){case"ArrowUp":this.output.index>0&&(this.output.rehighlight(this.list,this.output.index-1),e.preventDefault());break;case"ArrowDown":this.output.index<this.output.choices.length-1&&(this.output.rehighlight(this.list,this.output.index+1),e.preventDefault())}}follow(e){if(e.preventDefault(),null===this.output||void 0===this.runner)return;const t=this.output.choices[this.output.index];window.location.assign(this.runner.symbols[parseInt(t.ref)].uri)}}function s(e){return e.toString(16).padStart(2,"0")}const o=document.getElementById("search"),a=document.getElementById("login");if(null!==o){const e=document.getElementById("search-input"),t=document.getElementById("search-results"),r=document.getElementById("search-packages-only");if(null!==e&&null!==t){const n=new i({input:e,mode:r,list:t}),s=e.getAttribute("placeholder")||"";e.addEventListener("focus",(e=>n.reinitialize())),e.addEventListener("mousedown",(function(t){e.setAttribute("placeholder","search shortcut: /")})),e.addEventListener("blur",(function(t){e.setAttribute("placeholder",s)})),e.addEventListener("keydown",(e=>n.navigate(e))),e.addEventListener("input",(e=>n.suggest())),r?.addEventListener("click",(e=>n.suggest())),document.addEventListener("keydown",(function(t){switch(t.key){case"Escape":document.activeElement===e&&e.blur();break;case"/":document.activeElement!==e&&(e.focus(),t.preventDefault());break;case",":null!==n.mode&&(n.mode.checked=!n.mode.checked,n.suggest(),e.focus(),t.preventDefault())}})),o.addEventListener("submit",(e=>n.follow(e)))}}if(null!==a){const e=document.createElement("input"),t=function(){const e=new Uint8Array(8);return Array.from(window.crypto.getRandomValues(e),s).join("")}();e.setAttribute("type","hidden"),e.setAttribute("name","state"),e.setAttribute("value",t),a.appendChild(e),document.cookie="login_state="+t+"; Path=/ ; SameSite=Lax ; Secure"}document.querySelectorAll("form.sort-controls").forEach(((e,t,r)=>{const n=e.nextElementSibling;null!==n&&e.querySelectorAll('input[type="radio"][value]').forEach(((e,t,r)=>{const i="data-"+e.getAttribute("value"),s=e.getAttribute("data-predicate");e.addEventListener("click",(e=>{const t=n.querySelectorAll("li"),r=Array.from(t).sort(((e,t)=>{const r=e.getAttribute(i),n=t.getAttribute(i);return null===r||null===n?0:null===s?r.localeCompare(n):"number-asc"===s?parseInt(r)-parseInt(n):"number-desc"===s?parseInt(n)-parseInt(r):0}));for(const e of r)n.appendChild(e)})),e.checked&&e.dispatchEvent(new Event("click"))}))}))})()})();
//# sourceMappingURL=Main.js.map