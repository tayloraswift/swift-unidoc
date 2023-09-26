/*! For license information please see Main.js.LICENSE.txt */
(()=>{var e={336:(e,t,r)=>{var n,i;!function(){var s,o,a,u,l,c,h,d,f,p,y,m,g,v,x,w,Q,b,k,E,S,L,P,T,I,O,R,C,F,_,N=function(e){var t=new N.Builder;return t.pipeline.add(N.trimmer,N.stopWordFilter,N.stemmer),t.searchPipeline.add(N.stemmer),e.call(t,t),t.build()};N.version="2.3.9",N.utils={},N.utils.warn=(s=this,function(e){s.console&&console.warn&&console.warn(e)}),N.utils.asString=function(e){return null==e?"":e.toString()},N.utils.clone=function(e){if(null==e)return e;for(var t=Object.create(null),r=Object.keys(e),n=0;n<r.length;n++){var i=r[n],s=e[i];if(Array.isArray(s))t[i]=s.slice();else{if("string"!=typeof s&&"number"!=typeof s&&"boolean"!=typeof s)throw new TypeError("clone is not deep and does not support nested objects");t[i]=s}}return t},N.FieldRef=function(e,t,r){this.docRef=e,this.fieldName=t,this._stringValue=r},N.FieldRef.joiner="/",N.FieldRef.fromString=function(e){var t=e.indexOf(N.FieldRef.joiner);if(-1===t)throw"malformed field ref string";var r=e.slice(0,t),n=e.slice(t+1);return new N.FieldRef(n,r,e)},N.FieldRef.prototype.toString=function(){return null==this._stringValue&&(this._stringValue=this.fieldName+N.FieldRef.joiner+this.docRef),this._stringValue},N.Set=function(e){if(this.elements=Object.create(null),e){this.length=e.length;for(var t=0;t<this.length;t++)this.elements[e[t]]=!0}else this.length=0},N.Set.complete={intersect:function(e){return e},union:function(){return this},contains:function(){return!0}},N.Set.empty={intersect:function(){return this},union:function(e){return e},contains:function(){return!1}},N.Set.prototype.contains=function(e){return!!this.elements[e]},N.Set.prototype.intersect=function(e){var t,r,n,i=[];if(e===N.Set.complete)return this;if(e===N.Set.empty)return e;this.length<e.length?(t=this,r=e):(t=e,r=this),n=Object.keys(t.elements);for(var s=0;s<n.length;s++){var o=n[s];o in r.elements&&i.push(o)}return new N.Set(i)},N.Set.prototype.union=function(e){return e===N.Set.complete?N.Set.complete:e===N.Set.empty?this:new N.Set(Object.keys(this.elements).concat(Object.keys(e.elements)))},N.idf=function(e,t){var r=0;for(var n in e)"_index"!=n&&(r+=Object.keys(e[n]).length);var i=(t-r+.5)/(r+.5);return Math.log(1+Math.abs(i))},N.Token=function(e,t){this.str=e||"",this.metadata=t||{}},N.Token.prototype.toString=function(){return this.str},N.Token.prototype.update=function(e){return this.str=e(this.str,this.metadata),this},N.Token.prototype.clone=function(e){return e=e||function(e){return e},new N.Token(e(this.str,this.metadata),this.metadata)},N.tokenizer=function(e,t){if(null==e||null==e)return[];if(Array.isArray(e))return e.map((function(e){return new N.Token(N.utils.asString(e).toLowerCase(),N.utils.clone(t))}));for(var r=e.toString().toLowerCase(),n=r.length,i=[],s=0,o=0;s<=n;s++){var a=s-o;if(r.charAt(s).match(N.tokenizer.separator)||s==n){if(a>0){var u=N.utils.clone(t)||{};u.position=[o,a],u.index=i.length,i.push(new N.Token(r.slice(o,s),u))}o=s+1}}return i},N.tokenizer.separator=/[\s\-]+/,N.Pipeline=function(){this._stack=[]},N.Pipeline.registeredFunctions=Object.create(null),N.Pipeline.registerFunction=function(e,t){t in this.registeredFunctions&&N.utils.warn("Overwriting existing registered function: "+t),e.label=t,N.Pipeline.registeredFunctions[e.label]=e},N.Pipeline.warnIfFunctionNotRegistered=function(e){e.label&&e.label in this.registeredFunctions||N.utils.warn("Function is not registered with pipeline. This may cause problems when serialising the index.\n",e)},N.Pipeline.load=function(e){var t=new N.Pipeline;return e.forEach((function(e){var r=N.Pipeline.registeredFunctions[e];if(!r)throw new Error("Cannot load unregistered function: "+e);t.add(r)})),t},N.Pipeline.prototype.add=function(){Array.prototype.slice.call(arguments).forEach((function(e){N.Pipeline.warnIfFunctionNotRegistered(e),this._stack.push(e)}),this)},N.Pipeline.prototype.after=function(e,t){N.Pipeline.warnIfFunctionNotRegistered(t);var r=this._stack.indexOf(e);if(-1==r)throw new Error("Cannot find existingFn");r+=1,this._stack.splice(r,0,t)},N.Pipeline.prototype.before=function(e,t){N.Pipeline.warnIfFunctionNotRegistered(t);var r=this._stack.indexOf(e);if(-1==r)throw new Error("Cannot find existingFn");this._stack.splice(r,0,t)},N.Pipeline.prototype.remove=function(e){var t=this._stack.indexOf(e);-1!=t&&this._stack.splice(t,1)},N.Pipeline.prototype.run=function(e){for(var t=this._stack.length,r=0;r<t;r++){for(var n=this._stack[r],i=[],s=0;s<e.length;s++){var o=n(e[s],s,e);if(null!=o&&""!==o)if(Array.isArray(o))for(var a=0;a<o.length;a++)i.push(o[a]);else i.push(o)}e=i}return e},N.Pipeline.prototype.runString=function(e,t){var r=new N.Token(e,t);return this.run([r]).map((function(e){return e.toString()}))},N.Pipeline.prototype.reset=function(){this._stack=[]},N.Pipeline.prototype.toJSON=function(){return this._stack.map((function(e){return N.Pipeline.warnIfFunctionNotRegistered(e),e.label}))},N.Vector=function(e){this._magnitude=0,this.elements=e||[]},N.Vector.prototype.positionForIndex=function(e){if(0==this.elements.length)return 0;for(var t=0,r=this.elements.length/2,n=r-t,i=Math.floor(n/2),s=this.elements[2*i];n>1&&(s<e&&(t=i),s>e&&(r=i),s!=e);)n=r-t,i=t+Math.floor(n/2),s=this.elements[2*i];return s==e||s>e?2*i:s<e?2*(i+1):void 0},N.Vector.prototype.insert=function(e,t){this.upsert(e,t,(function(){throw"duplicate index"}))},N.Vector.prototype.upsert=function(e,t,r){this._magnitude=0;var n=this.positionForIndex(e);this.elements[n]==e?this.elements[n+1]=r(this.elements[n+1],t):this.elements.splice(n,0,e,t)},N.Vector.prototype.magnitude=function(){if(this._magnitude)return this._magnitude;for(var e=0,t=this.elements.length,r=1;r<t;r+=2){var n=this.elements[r];e+=n*n}return this._magnitude=Math.sqrt(e)},N.Vector.prototype.dot=function(e){for(var t=0,r=this.elements,n=e.elements,i=r.length,s=n.length,o=0,a=0,u=0,l=0;u<i&&l<s;)(o=r[u])<(a=n[l])?u+=2:o>a?l+=2:o==a&&(t+=r[u+1]*n[l+1],u+=2,l+=2);return t},N.Vector.prototype.similarity=function(e){return this.dot(e)/this.magnitude()||0},N.Vector.prototype.toArray=function(){for(var e=new Array(this.elements.length/2),t=1,r=0;t<this.elements.length;t+=2,r++)e[r]=this.elements[t];return e},N.Vector.prototype.toJSON=function(){return this.elements},N.stemmer=(o={ational:"ate",tional:"tion",enci:"ence",anci:"ance",izer:"ize",bli:"ble",alli:"al",entli:"ent",eli:"e",ousli:"ous",ization:"ize",ation:"ate",ator:"ate",alism:"al",iveness:"ive",fulness:"ful",ousness:"ous",aliti:"al",iviti:"ive",biliti:"ble",logi:"log"},a={icate:"ic",ative:"",alize:"al",iciti:"ic",ical:"ic",ful:"",ness:""},h="^("+(l="[^aeiou][^aeiouy]*")+")?"+(c=(u="[aeiouy]")+"[aeiou]*")+l+"("+c+")?$",d="^("+l+")?"+c+l+c+l,f="^("+l+")?"+u,p=new RegExp("^("+l+")?"+c+l),y=new RegExp(d),m=new RegExp(h),g=new RegExp(f),v=/^(.+?)(ss|i)es$/,x=/^(.+?)([^s])s$/,w=/^(.+?)eed$/,Q=/^(.+?)(ed|ing)$/,b=/.$/,k=/(at|bl|iz)$/,E=new RegExp("([^aeiouylsz])\\1$"),S=new RegExp("^"+l+u+"[^aeiouwxy]$"),L=/^(.+?[^aeiou])y$/,P=/^(.+?)(ational|tional|enci|anci|izer|bli|alli|entli|eli|ousli|ization|ation|ator|alism|iveness|fulness|ousness|aliti|iviti|biliti|logi)$/,T=/^(.+?)(icate|ative|alize|iciti|ical|ful|ness)$/,I=/^(.+?)(al|ance|ence|er|ic|able|ible|ant|ement|ment|ent|ou|ism|ate|iti|ous|ive|ize)$/,O=/^(.+?)(s|t)(ion)$/,R=/^(.+?)e$/,C=/ll$/,F=new RegExp("^"+l+u+"[^aeiouwxy]$"),_=function(e){var t,r,n,i,s,u,l;if(e.length<3)return e;if("y"==(n=e.substr(0,1))&&(e=n.toUpperCase()+e.substr(1)),s=x,(i=v).test(e)?e=e.replace(i,"$1$2"):s.test(e)&&(e=e.replace(s,"$1$2")),s=Q,(i=w).test(e)){var c=i.exec(e);(i=p).test(c[1])&&(i=b,e=e.replace(i,""))}else s.test(e)&&(t=(c=s.exec(e))[1],(s=g).test(t)&&(u=E,l=S,(s=k).test(e=t)?e+="e":u.test(e)?(i=b,e=e.replace(i,"")):l.test(e)&&(e+="e")));return(i=L).test(e)&&(e=(t=(c=i.exec(e))[1])+"i"),(i=P).test(e)&&(t=(c=i.exec(e))[1],r=c[2],(i=p).test(t)&&(e=t+o[r])),(i=T).test(e)&&(t=(c=i.exec(e))[1],r=c[2],(i=p).test(t)&&(e=t+a[r])),s=O,(i=I).test(e)?(t=(c=i.exec(e))[1],(i=y).test(t)&&(e=t)):s.test(e)&&(t=(c=s.exec(e))[1]+c[2],(s=y).test(t)&&(e=t)),(i=R).test(e)&&(t=(c=i.exec(e))[1],s=m,u=F,((i=y).test(t)||s.test(t)&&!u.test(t))&&(e=t)),s=y,(i=C).test(e)&&s.test(e)&&(i=b,e=e.replace(i,"")),"y"==n&&(e=n.toLowerCase()+e.substr(1)),e},function(e){return e.update(_)}),N.Pipeline.registerFunction(N.stemmer,"stemmer"),N.generateStopWordFilter=function(e){var t=e.reduce((function(e,t){return e[t]=t,e}),{});return function(e){if(e&&t[e.toString()]!==e.toString())return e}},N.stopWordFilter=N.generateStopWordFilter(["a","able","about","across","after","all","almost","also","am","among","an","and","any","are","as","at","be","because","been","but","by","can","cannot","could","dear","did","do","does","either","else","ever","every","for","from","get","got","had","has","have","he","her","hers","him","his","how","however","i","if","in","into","is","it","its","just","least","let","like","likely","may","me","might","most","must","my","neither","no","nor","not","of","off","often","on","only","or","other","our","own","rather","said","say","says","she","should","since","so","some","than","that","the","their","them","then","there","these","they","this","tis","to","too","twas","us","wants","was","we","were","what","when","where","which","while","who","whom","why","will","with","would","yet","you","your"]),N.Pipeline.registerFunction(N.stopWordFilter,"stopWordFilter"),N.trimmer=function(e){return e.update((function(e){return e.replace(/^\W+/,"").replace(/\W+$/,"")}))},N.Pipeline.registerFunction(N.trimmer,"trimmer"),N.TokenSet=function(){this.final=!1,this.edges={},this.id=N.TokenSet._nextId,N.TokenSet._nextId+=1},N.TokenSet._nextId=1,N.TokenSet.fromArray=function(e){for(var t=new N.TokenSet.Builder,r=0,n=e.length;r<n;r++)t.insert(e[r]);return t.finish(),t.root},N.TokenSet.fromClause=function(e){return"editDistance"in e?N.TokenSet.fromFuzzyString(e.term,e.editDistance):N.TokenSet.fromString(e.term)},N.TokenSet.fromFuzzyString=function(e,t){for(var r=new N.TokenSet,n=[{node:r,editsRemaining:t,str:e}];n.length;){var i=n.pop();if(i.str.length>0){var s,o=i.str.charAt(0);o in i.node.edges?s=i.node.edges[o]:(s=new N.TokenSet,i.node.edges[o]=s),1==i.str.length&&(s.final=!0),n.push({node:s,editsRemaining:i.editsRemaining,str:i.str.slice(1)})}if(0!=i.editsRemaining){if("*"in i.node.edges)var a=i.node.edges["*"];else a=new N.TokenSet,i.node.edges["*"]=a;if(0==i.str.length&&(a.final=!0),n.push({node:a,editsRemaining:i.editsRemaining-1,str:i.str}),i.str.length>1&&n.push({node:i.node,editsRemaining:i.editsRemaining-1,str:i.str.slice(1)}),1==i.str.length&&(i.node.final=!0),i.str.length>=1){if("*"in i.node.edges)var u=i.node.edges["*"];else u=new N.TokenSet,i.node.edges["*"]=u;1==i.str.length&&(u.final=!0),n.push({node:u,editsRemaining:i.editsRemaining-1,str:i.str.slice(1)})}if(i.str.length>1){var l,c=i.str.charAt(0),h=i.str.charAt(1);h in i.node.edges?l=i.node.edges[h]:(l=new N.TokenSet,i.node.edges[h]=l),1==i.str.length&&(l.final=!0),n.push({node:l,editsRemaining:i.editsRemaining-1,str:c+i.str.slice(2)})}}}return r},N.TokenSet.fromString=function(e){for(var t=new N.TokenSet,r=t,n=0,i=e.length;n<i;n++){var s=e[n],o=n==i-1;if("*"==s)t.edges[s]=t,t.final=o;else{var a=new N.TokenSet;a.final=o,t.edges[s]=a,t=a}}return r},N.TokenSet.prototype.toArray=function(){for(var e=[],t=[{prefix:"",node:this}];t.length;){var r=t.pop(),n=Object.keys(r.node.edges),i=n.length;r.node.final&&(r.prefix.charAt(0),e.push(r.prefix));for(var s=0;s<i;s++){var o=n[s];t.push({prefix:r.prefix.concat(o),node:r.node.edges[o]})}}return e},N.TokenSet.prototype.toString=function(){if(this._str)return this._str;for(var e=this.final?"1":"0",t=Object.keys(this.edges).sort(),r=t.length,n=0;n<r;n++){var i=t[n];e=e+i+this.edges[i].id}return e},N.TokenSet.prototype.intersect=function(e){for(var t=new N.TokenSet,r=void 0,n=[{qNode:e,output:t,node:this}];n.length;){r=n.pop();for(var i=Object.keys(r.qNode.edges),s=i.length,o=Object.keys(r.node.edges),a=o.length,u=0;u<s;u++)for(var l=i[u],c=0;c<a;c++){var h=o[c];if(h==l||"*"==l){var d=r.node.edges[h],f=r.qNode.edges[l],p=d.final&&f.final,y=void 0;h in r.output.edges?(y=r.output.edges[h]).final=y.final||p:((y=new N.TokenSet).final=p,r.output.edges[h]=y),n.push({qNode:f,output:y,node:d})}}}return t},N.TokenSet.Builder=function(){this.previousWord="",this.root=new N.TokenSet,this.uncheckedNodes=[],this.minimizedNodes={}},N.TokenSet.Builder.prototype.insert=function(e){var t,r=0;if(e<this.previousWord)throw new Error("Out of order word insertion");for(var n=0;n<e.length&&n<this.previousWord.length&&e[n]==this.previousWord[n];n++)r++;for(this.minimize(r),t=0==this.uncheckedNodes.length?this.root:this.uncheckedNodes[this.uncheckedNodes.length-1].child,n=r;n<e.length;n++){var i=new N.TokenSet,s=e[n];t.edges[s]=i,this.uncheckedNodes.push({parent:t,char:s,child:i}),t=i}t.final=!0,this.previousWord=e},N.TokenSet.Builder.prototype.finish=function(){this.minimize(0)},N.TokenSet.Builder.prototype.minimize=function(e){for(var t=this.uncheckedNodes.length-1;t>=e;t--){var r=this.uncheckedNodes[t],n=r.child.toString();n in this.minimizedNodes?r.parent.edges[r.char]=this.minimizedNodes[n]:(r.child._str=n,this.minimizedNodes[n]=r.child),this.uncheckedNodes.pop()}},N.Index=function(e){this.invertedIndex=e.invertedIndex,this.fieldVectors=e.fieldVectors,this.tokenSet=e.tokenSet,this.fields=e.fields,this.pipeline=e.pipeline},N.Index.prototype.search=function(e){return this.query((function(t){new N.QueryParser(e,t).parse()}))},N.Index.prototype.query=function(e){for(var t=new N.Query(this.fields),r=Object.create(null),n=Object.create(null),i=Object.create(null),s=Object.create(null),o=Object.create(null),a=0;a<this.fields.length;a++)n[this.fields[a]]=new N.Vector;for(e.call(t,t),a=0;a<t.clauses.length;a++){var u,l=t.clauses[a],c=N.Set.empty;u=l.usePipeline?this.pipeline.runString(l.term,{fields:l.fields}):[l.term];for(var h=0;h<u.length;h++){var d=u[h];l.term=d;var f=N.TokenSet.fromClause(l),p=this.tokenSet.intersect(f).toArray();if(0===p.length&&l.presence===N.Query.presence.REQUIRED){for(var y=0;y<l.fields.length;y++)s[R=l.fields[y]]=N.Set.empty;break}for(var m=0;m<p.length;m++){var g=p[m],v=this.invertedIndex[g],x=v._index;for(y=0;y<l.fields.length;y++){var w=v[R=l.fields[y]],Q=Object.keys(w),b=g+"/"+R,k=new N.Set(Q);if(l.presence==N.Query.presence.REQUIRED&&(c=c.union(k),void 0===s[R]&&(s[R]=N.Set.complete)),l.presence!=N.Query.presence.PROHIBITED){if(n[R].upsert(x,l.boost,(function(e,t){return e+t})),!i[b]){for(var E=0;E<Q.length;E++){var S,L=Q[E],P=new N.FieldRef(L,R),T=w[L];void 0===(S=r[P])?r[P]=new N.MatchData(g,R,T):S.add(g,R,T)}i[b]=!0}}else void 0===o[R]&&(o[R]=N.Set.empty),o[R]=o[R].union(k)}}}if(l.presence===N.Query.presence.REQUIRED)for(y=0;y<l.fields.length;y++)s[R=l.fields[y]]=s[R].intersect(c)}var I=N.Set.complete,O=N.Set.empty;for(a=0;a<this.fields.length;a++){var R;s[R=this.fields[a]]&&(I=I.intersect(s[R])),o[R]&&(O=O.union(o[R]))}var C=Object.keys(r),F=[],_=Object.create(null);if(t.isNegated())for(C=Object.keys(this.fieldVectors),a=0;a<C.length;a++){P=C[a];var j=N.FieldRef.fromString(P);r[P]=new N.MatchData}for(a=0;a<C.length;a++){var D=(j=N.FieldRef.fromString(C[a])).docRef;if(I.contains(D)&&!O.contains(D)){var A,B=this.fieldVectors[j],z=n[j.fieldName].similarity(B);if(void 0!==(A=_[D]))A.score+=z,A.matchData.combine(r[j]);else{var V={ref:D,score:z,matchData:r[j]};_[D]=V,F.push(V)}}}return F.sort((function(e,t){return t.score-e.score}))},N.Index.prototype.toJSON=function(){var e=Object.keys(this.invertedIndex).sort().map((function(e){return[e,this.invertedIndex[e]]}),this),t=Object.keys(this.fieldVectors).map((function(e){return[e,this.fieldVectors[e].toJSON()]}),this);return{version:N.version,fields:this.fields,fieldVectors:t,invertedIndex:e,pipeline:this.pipeline.toJSON()}},N.Index.load=function(e){var t={},r={},n=e.fieldVectors,i=Object.create(null),s=e.invertedIndex,o=new N.TokenSet.Builder,a=N.Pipeline.load(e.pipeline);e.version!=N.version&&N.utils.warn("Version mismatch when loading serialised index. Current version of lunr '"+N.version+"' does not match serialized index '"+e.version+"'");for(var u=0;u<n.length;u++){var l=(h=n[u])[0],c=h[1];r[l]=new N.Vector(c)}for(u=0;u<s.length;u++){var h,d=(h=s[u])[0],f=h[1];o.insert(d),i[d]=f}return o.finish(),t.fields=e.fields,t.fieldVectors=r,t.invertedIndex=i,t.tokenSet=o.root,t.pipeline=a,new N.Index(t)},N.Builder=function(){this._ref="id",this._fields=Object.create(null),this._documents=Object.create(null),this.invertedIndex=Object.create(null),this.fieldTermFrequencies={},this.fieldLengths={},this.tokenizer=N.tokenizer,this.pipeline=new N.Pipeline,this.searchPipeline=new N.Pipeline,this.documentCount=0,this._b=.75,this._k1=1.2,this.termIndex=0,this.metadataWhitelist=[]},N.Builder.prototype.ref=function(e){this._ref=e},N.Builder.prototype.field=function(e,t){if(/\//.test(e))throw new RangeError("Field '"+e+"' contains illegal character '/'");this._fields[e]=t||{}},N.Builder.prototype.b=function(e){this._b=e<0?0:e>1?1:e},N.Builder.prototype.k1=function(e){this._k1=e},N.Builder.prototype.add=function(e,t){var r=e[this._ref],n=Object.keys(this._fields);this._documents[r]=t||{},this.documentCount+=1;for(var i=0;i<n.length;i++){var s=n[i],o=this._fields[s].extractor,a=o?o(e):e[s],u=this.tokenizer(a,{fields:[s]}),l=this.pipeline.run(u),c=new N.FieldRef(r,s),h=Object.create(null);this.fieldTermFrequencies[c]=h,this.fieldLengths[c]=0,this.fieldLengths[c]+=l.length;for(var d=0;d<l.length;d++){var f=l[d];if(null==h[f]&&(h[f]=0),h[f]+=1,null==this.invertedIndex[f]){var p=Object.create(null);p._index=this.termIndex,this.termIndex+=1;for(var y=0;y<n.length;y++)p[n[y]]=Object.create(null);this.invertedIndex[f]=p}null==this.invertedIndex[f][s][r]&&(this.invertedIndex[f][s][r]=Object.create(null));for(var m=0;m<this.metadataWhitelist.length;m++){var g=this.metadataWhitelist[m],v=f.metadata[g];null==this.invertedIndex[f][s][r][g]&&(this.invertedIndex[f][s][r][g]=[]),this.invertedIndex[f][s][r][g].push(v)}}}},N.Builder.prototype.calculateAverageFieldLengths=function(){for(var e=Object.keys(this.fieldLengths),t=e.length,r={},n={},i=0;i<t;i++){var s=N.FieldRef.fromString(e[i]),o=s.fieldName;n[o]||(n[o]=0),n[o]+=1,r[o]||(r[o]=0),r[o]+=this.fieldLengths[s]}var a=Object.keys(this._fields);for(i=0;i<a.length;i++){var u=a[i];r[u]=r[u]/n[u]}this.averageFieldLength=r},N.Builder.prototype.createFieldVectors=function(){for(var e={},t=Object.keys(this.fieldTermFrequencies),r=t.length,n=Object.create(null),i=0;i<r;i++){for(var s=N.FieldRef.fromString(t[i]),o=s.fieldName,a=this.fieldLengths[s],u=new N.Vector,l=this.fieldTermFrequencies[s],c=Object.keys(l),h=c.length,d=this._fields[o].boost||1,f=this._documents[s.docRef].boost||1,p=0;p<h;p++){var y,m,g,v=c[p],x=l[v],w=this.invertedIndex[v]._index;void 0===n[v]?(y=N.idf(this.invertedIndex[v],this.documentCount),n[v]=y):y=n[v],m=y*((this._k1+1)*x)/(this._k1*(1-this._b+this._b*(a/this.averageFieldLength[o]))+x),m*=d,m*=f,g=Math.round(1e3*m)/1e3,u.insert(w,g)}e[s]=u}this.fieldVectors=e},N.Builder.prototype.createTokenSet=function(){this.tokenSet=N.TokenSet.fromArray(Object.keys(this.invertedIndex).sort())},N.Builder.prototype.build=function(){return this.calculateAverageFieldLengths(),this.createFieldVectors(),this.createTokenSet(),new N.Index({invertedIndex:this.invertedIndex,fieldVectors:this.fieldVectors,tokenSet:this.tokenSet,fields:Object.keys(this._fields),pipeline:this.searchPipeline})},N.Builder.prototype.use=function(e){var t=Array.prototype.slice.call(arguments,1);t.unshift(this),e.apply(this,t)},N.MatchData=function(e,t,r){for(var n=Object.create(null),i=Object.keys(r||{}),s=0;s<i.length;s++){var o=i[s];n[o]=r[o].slice()}this.metadata=Object.create(null),void 0!==e&&(this.metadata[e]=Object.create(null),this.metadata[e][t]=n)},N.MatchData.prototype.combine=function(e){for(var t=Object.keys(e.metadata),r=0;r<t.length;r++){var n=t[r],i=Object.keys(e.metadata[n]);null==this.metadata[n]&&(this.metadata[n]=Object.create(null));for(var s=0;s<i.length;s++){var o=i[s],a=Object.keys(e.metadata[n][o]);null==this.metadata[n][o]&&(this.metadata[n][o]=Object.create(null));for(var u=0;u<a.length;u++){var l=a[u];null==this.metadata[n][o][l]?this.metadata[n][o][l]=e.metadata[n][o][l]:this.metadata[n][o][l]=this.metadata[n][o][l].concat(e.metadata[n][o][l])}}}},N.MatchData.prototype.add=function(e,t,r){if(!(e in this.metadata))return this.metadata[e]=Object.create(null),void(this.metadata[e][t]=r);if(t in this.metadata[e])for(var n=Object.keys(r),i=0;i<n.length;i++){var s=n[i];s in this.metadata[e][t]?this.metadata[e][t][s]=this.metadata[e][t][s].concat(r[s]):this.metadata[e][t][s]=r[s]}else this.metadata[e][t]=r},N.Query=function(e){this.clauses=[],this.allFields=e},N.Query.wildcard=new String("*"),N.Query.wildcard.NONE=0,N.Query.wildcard.LEADING=1,N.Query.wildcard.TRAILING=2,N.Query.presence={OPTIONAL:1,REQUIRED:2,PROHIBITED:3},N.Query.prototype.clause=function(e){return"fields"in e||(e.fields=this.allFields),"boost"in e||(e.boost=1),"usePipeline"in e||(e.usePipeline=!0),"wildcard"in e||(e.wildcard=N.Query.wildcard.NONE),e.wildcard&N.Query.wildcard.LEADING&&e.term.charAt(0)!=N.Query.wildcard&&(e.term="*"+e.term),e.wildcard&N.Query.wildcard.TRAILING&&e.term.slice(-1)!=N.Query.wildcard&&(e.term=e.term+"*"),"presence"in e||(e.presence=N.Query.presence.OPTIONAL),this.clauses.push(e),this},N.Query.prototype.isNegated=function(){for(var e=0;e<this.clauses.length;e++)if(this.clauses[e].presence!=N.Query.presence.PROHIBITED)return!1;return!0},N.Query.prototype.term=function(e,t){if(Array.isArray(e))return e.forEach((function(e){this.term(e,N.utils.clone(t))}),this),this;var r=t||{};return r.term=e.toString(),this.clause(r),this},N.QueryParseError=function(e,t,r){this.name="QueryParseError",this.message=e,this.start=t,this.end=r},N.QueryParseError.prototype=new Error,N.QueryLexer=function(e){this.lexemes=[],this.str=e,this.length=e.length,this.pos=0,this.start=0,this.escapeCharPositions=[]},N.QueryLexer.prototype.run=function(){for(var e=N.QueryLexer.lexText;e;)e=e(this)},N.QueryLexer.prototype.sliceString=function(){for(var e=[],t=this.start,r=this.pos,n=0;n<this.escapeCharPositions.length;n++)r=this.escapeCharPositions[n],e.push(this.str.slice(t,r)),t=r+1;return e.push(this.str.slice(t,this.pos)),this.escapeCharPositions.length=0,e.join("")},N.QueryLexer.prototype.emit=function(e){this.lexemes.push({type:e,str:this.sliceString(),start:this.start,end:this.pos}),this.start=this.pos},N.QueryLexer.prototype.escapeCharacter=function(){this.escapeCharPositions.push(this.pos-1),this.pos+=1},N.QueryLexer.prototype.next=function(){if(this.pos>=this.length)return N.QueryLexer.EOS;var e=this.str.charAt(this.pos);return this.pos+=1,e},N.QueryLexer.prototype.width=function(){return this.pos-this.start},N.QueryLexer.prototype.ignore=function(){this.start==this.pos&&(this.pos+=1),this.start=this.pos},N.QueryLexer.prototype.backup=function(){this.pos-=1},N.QueryLexer.prototype.acceptDigitRun=function(){var e,t;do{t=(e=this.next()).charCodeAt(0)}while(t>47&&t<58);e!=N.QueryLexer.EOS&&this.backup()},N.QueryLexer.prototype.more=function(){return this.pos<this.length},N.QueryLexer.EOS="EOS",N.QueryLexer.FIELD="FIELD",N.QueryLexer.TERM="TERM",N.QueryLexer.EDIT_DISTANCE="EDIT_DISTANCE",N.QueryLexer.BOOST="BOOST",N.QueryLexer.PRESENCE="PRESENCE",N.QueryLexer.lexField=function(e){return e.backup(),e.emit(N.QueryLexer.FIELD),e.ignore(),N.QueryLexer.lexText},N.QueryLexer.lexTerm=function(e){if(e.width()>1&&(e.backup(),e.emit(N.QueryLexer.TERM)),e.ignore(),e.more())return N.QueryLexer.lexText},N.QueryLexer.lexEditDistance=function(e){return e.ignore(),e.acceptDigitRun(),e.emit(N.QueryLexer.EDIT_DISTANCE),N.QueryLexer.lexText},N.QueryLexer.lexBoost=function(e){return e.ignore(),e.acceptDigitRun(),e.emit(N.QueryLexer.BOOST),N.QueryLexer.lexText},N.QueryLexer.lexEOS=function(e){e.width()>0&&e.emit(N.QueryLexer.TERM)},N.QueryLexer.termSeparator=N.tokenizer.separator,N.QueryLexer.lexText=function(e){for(;;){var t=e.next();if(t==N.QueryLexer.EOS)return N.QueryLexer.lexEOS;if(92!=t.charCodeAt(0)){if(":"==t)return N.QueryLexer.lexField;if("~"==t)return e.backup(),e.width()>0&&e.emit(N.QueryLexer.TERM),N.QueryLexer.lexEditDistance;if("^"==t)return e.backup(),e.width()>0&&e.emit(N.QueryLexer.TERM),N.QueryLexer.lexBoost;if("+"==t&&1===e.width())return e.emit(N.QueryLexer.PRESENCE),N.QueryLexer.lexText;if("-"==t&&1===e.width())return e.emit(N.QueryLexer.PRESENCE),N.QueryLexer.lexText;if(t.match(N.QueryLexer.termSeparator))return N.QueryLexer.lexTerm}else e.escapeCharacter()}},N.QueryParser=function(e,t){this.lexer=new N.QueryLexer(e),this.query=t,this.currentClause={},this.lexemeIdx=0},N.QueryParser.prototype.parse=function(){this.lexer.run(),this.lexemes=this.lexer.lexemes;for(var e=N.QueryParser.parseClause;e;)e=e(this);return this.query},N.QueryParser.prototype.peekLexeme=function(){return this.lexemes[this.lexemeIdx]},N.QueryParser.prototype.consumeLexeme=function(){var e=this.peekLexeme();return this.lexemeIdx+=1,e},N.QueryParser.prototype.nextClause=function(){var e=this.currentClause;this.query.clause(e),this.currentClause={}},N.QueryParser.parseClause=function(e){var t=e.peekLexeme();if(null!=t)switch(t.type){case N.QueryLexer.PRESENCE:return N.QueryParser.parsePresence;case N.QueryLexer.FIELD:return N.QueryParser.parseField;case N.QueryLexer.TERM:return N.QueryParser.parseTerm;default:var r="expected either a field or a term, found "+t.type;throw t.str.length>=1&&(r+=" with value '"+t.str+"'"),new N.QueryParseError(r,t.start,t.end)}},N.QueryParser.parsePresence=function(e){var t=e.consumeLexeme();if(null!=t){switch(t.str){case"-":e.currentClause.presence=N.Query.presence.PROHIBITED;break;case"+":e.currentClause.presence=N.Query.presence.REQUIRED;break;default:var r="unrecognised presence operator'"+t.str+"'";throw new N.QueryParseError(r,t.start,t.end)}var n=e.peekLexeme();if(null==n)throw r="expecting term or field, found nothing",new N.QueryParseError(r,t.start,t.end);switch(n.type){case N.QueryLexer.FIELD:return N.QueryParser.parseField;case N.QueryLexer.TERM:return N.QueryParser.parseTerm;default:throw r="expecting term or field, found '"+n.type+"'",new N.QueryParseError(r,n.start,n.end)}}},N.QueryParser.parseField=function(e){var t=e.consumeLexeme();if(null!=t){if(-1==e.query.allFields.indexOf(t.str)){var r=e.query.allFields.map((function(e){return"'"+e+"'"})).join(", "),n="unrecognised field '"+t.str+"', possible fields: "+r;throw new N.QueryParseError(n,t.start,t.end)}e.currentClause.fields=[t.str];var i=e.peekLexeme();if(null==i)throw n="expecting term, found nothing",new N.QueryParseError(n,t.start,t.end);if(i.type===N.QueryLexer.TERM)return N.QueryParser.parseTerm;throw n="expecting term, found '"+i.type+"'",new N.QueryParseError(n,i.start,i.end)}},N.QueryParser.parseTerm=function(e){var t=e.consumeLexeme();if(null!=t){e.currentClause.term=t.str.toLowerCase(),-1!=t.str.indexOf("*")&&(e.currentClause.usePipeline=!1);var r=e.peekLexeme();if(null!=r)switch(r.type){case N.QueryLexer.TERM:return e.nextClause(),N.QueryParser.parseTerm;case N.QueryLexer.FIELD:return e.nextClause(),N.QueryParser.parseField;case N.QueryLexer.EDIT_DISTANCE:return N.QueryParser.parseEditDistance;case N.QueryLexer.BOOST:return N.QueryParser.parseBoost;case N.QueryLexer.PRESENCE:return e.nextClause(),N.QueryParser.parsePresence;default:var n="Unexpected lexeme type '"+r.type+"'";throw new N.QueryParseError(n,r.start,r.end)}else e.nextClause()}},N.QueryParser.parseEditDistance=function(e){var t=e.consumeLexeme();if(null!=t){var r=parseInt(t.str,10);if(isNaN(r)){var n="edit distance must be numeric";throw new N.QueryParseError(n,t.start,t.end)}e.currentClause.editDistance=r;var i=e.peekLexeme();if(null!=i)switch(i.type){case N.QueryLexer.TERM:return e.nextClause(),N.QueryParser.parseTerm;case N.QueryLexer.FIELD:return e.nextClause(),N.QueryParser.parseField;case N.QueryLexer.EDIT_DISTANCE:return N.QueryParser.parseEditDistance;case N.QueryLexer.BOOST:return N.QueryParser.parseBoost;case N.QueryLexer.PRESENCE:return e.nextClause(),N.QueryParser.parsePresence;default:throw n="Unexpected lexeme type '"+i.type+"'",new N.QueryParseError(n,i.start,i.end)}else e.nextClause()}},N.QueryParser.parseBoost=function(e){var t=e.consumeLexeme();if(null!=t){var r=parseInt(t.str,10);if(isNaN(r)){var n="boost must be numeric";throw new N.QueryParseError(n,t.start,t.end)}e.currentClause.boost=r;var i=e.peekLexeme();if(null!=i)switch(i.type){case N.QueryLexer.TERM:return e.nextClause(),N.QueryParser.parseTerm;case N.QueryLexer.FIELD:return e.nextClause(),N.QueryParser.parseField;case N.QueryLexer.EDIT_DISTANCE:return N.QueryParser.parseEditDistance;case N.QueryLexer.BOOST:return N.QueryParser.parseBoost;case N.QueryLexer.PRESENCE:return e.nextClause(),N.QueryParser.parsePresence;default:throw n="Unexpected lexeme type '"+i.type+"'",new N.QueryParseError(n,i.start,i.end)}else e.nextClause()}},void 0===(i="function"==typeof(n=function(){return N})?n.call(t,r,t,e):n)||(e.exports=i)}()},845:(e,t)=>{"use strict";Object.defineProperty(t,"__esModule",{value:!0}),t.SearchOutput=void 0;var r=function(){function e(e){this.index=0,this.choices=e}return e.prototype.highlight=function(e){var t=e.children.item(this.index);t instanceof HTMLElement&&t.classList.add("selected")},e.prototype.rehighlight=function(e,t){if(t!=this.index){var r=e.children.item(this.index);r instanceof HTMLElement&&(r.classList.remove("selected"),0==r.classList.length&&r.removeAttribute("class"),this.index=t,this.highlight(e))}},e}();t.SearchOutput=r},235:(e,t,r)=>{"use strict";Object.defineProperty(t,"__esModule",{value:!0}),t.SearchRunner=void 0;var n=r(336),i=r(845),s=function(){function e(e){this.symbols=e,this.index=n((function(){this.ref("i"),this.field("text"),this.pipeline.remove(n.stemmer),this.searchPipeline.remove(n.stemmer);for(var t=0;t<e.length;t++)this.add({i:t,text:e[t].signature})}))}return e.prototype.search=function(e){var t;return(t=e.length>0?this.index.query((function(t){t.term(e,{boost:100}),t.term(e,{boost:10,wildcard:n.Query.wildcard.TRAILING}),t.term(e,{boost:5,wildcard:n.Query.wildcard.TRAILING,editDistance:1}),t.term(e,{boost:1,wildcard:n.Query.wildcard.TRAILING,editDistance:2})})):[]).length>0?new i.SearchOutput(t.slice(0,10)):void 0},e}();t.SearchRunner=s},223:function(e,t,r){"use strict";var n=this&&this.__awaiter||function(e,t,r,n){return new(r||(r=Promise))((function(i,s){function o(e){try{u(n.next(e))}catch(e){s(e)}}function a(e){try{u(n.throw(e))}catch(e){s(e)}}function u(e){var t;e.done?i(e.value):(t=e.value,t instanceof r?t:new r((function(e){e(t)}))).then(o,a)}u((n=n.apply(e,t||[])).next())}))},i=this&&this.__generator||function(e,t){var r,n,i,s,o={label:0,sent:function(){if(1&i[0])throw i[1];return i[1]},trys:[],ops:[]};return s={next:a(0),throw:a(1),return:a(2)},"function"==typeof Symbol&&(s[Symbol.iterator]=function(){return this}),s;function a(a){return function(u){return function(a){if(r)throw new TypeError("Generator is already executing.");for(;s&&(s=0,a[0]&&(o=0)),o;)try{if(r=1,n&&(i=2&a[0]?n.return:a[0]?n.throw||((i=n.return)&&i.call(n),0):n.next)&&!(i=i.call(n,a[1])).done)return i;switch(n=0,i&&(a=[2&a[0],i.value]),a[0]){case 0:case 1:i=a;break;case 4:return o.label++,{value:a[1],done:!1};case 5:o.label++,n=a[1],a=[0];continue;case 7:a=o.ops.pop(),o.trys.pop();continue;default:if(!((i=(i=o.trys).length>0&&i[i.length-1])||6!==a[0]&&2!==a[0])){o=0;continue}if(3===a[0]&&(!i||a[1]>i[0]&&a[1]<i[3])){o.label=a[1];break}if(6===a[0]&&o.label<i[1]){o.label=i[1],i=a;break}if(i&&o.label<i[2]){o.label=i[2],o.ops.push(a);break}i[2]&&o.ops.pop(),o.trys.pop();continue}a=t.call(e,o)}catch(e){a=[6,e],n=0}finally{r=i=0}if(5&a[0])throw a[1];return{value:a[0]?a[1]:void 0,done:!0}}([a,u])}}};Object.defineProperty(t,"__esModule",{value:!0}),t.Searchbar=void 0;var s=r(235),o=function(){function e(e){this.loading=!1,this.list=e.list}return e.prototype.focus=function(){return n(this,void 0,void 0,(function(){return i(this,(function(e){switch(e.label){case 0:return this.list.classList.remove("occluded"),[4,this.reinitialize()];case 1:return e.sent(),[2]}}))}))},e.prototype.reinitialize=function(){return n(this,void 0,void 0,(function(){var e,t,r,o,a,u;return i(this,(function(l){switch(l.label){case 0:if(console.log("Reinitializing search index"),this.loading||void 0!==this.runner)return[2];for(this.loading=!0,e=[fetch("/lunr/packages.json").then((function(e){return n(this,void 0,void 0,(function(){return i(this,(function(t){return[2,e.json().then((function(e){return{packages:e,cultures:[]}}))]}))}))}))],t=0,r=volumes;t<r.length;t++)o=r[t],a="/lunr/"+o,e.push(fetch(a).then((function(e){return n(this,void 0,void 0,(function(){return i(this,(function(t){return[2,e.json().then((function(e){return{packages:[],cultures:e}}))]}))}))})));return u=this,[4,Promise.all(e).then((function(e){for(var t=[],r=window.location.pathname.split("/"),n=0,i=e;n<i.length;n++){for(var o=i[n],a=0,u=o.packages;a<u.length;a++){var l=u[a];t.push({module:null,signature:l.split(/\-/),display:l,uri:"/docs/"+l})}for(var c=0,h=o.cultures;c<h.length;c++)for(var d=h[c],f=d.c,p=0,y=d.n;p<y.length;p++){var m=y[p],g="/"+r[1]+"/"+r[2]+"/";g+=m.s.replace("\t",".").replaceAll(" ","/").toLowerCase();var v=m.s.split(/\s+/);t.push({module:f,signature:v,display:v.slice(1).join("."),uri:g})}}return new s.SearchRunner(t)})).catch((function(e){console.error("error:",e)}))];case 1:return u.runner=l.sent(),this.loading=!1,void 0!==this.pending&&this.suggest(this.pending),[2]}}))}))},e.prototype.suggest=function(e){var t;if(void 0!==this.runner){this.pending=void 0;var r=e.target;if(this.output=this.runner.search(r.value.toLowerCase()),void 0!==this.output){for(var n=[],i=0,s=this.output.choices;i<s.length;i++){var o=s[i],a=this.runner.symbols[parseInt(o.ref)],u=document.createElement("li"),l=document.createElement("a"),c=document.createElement("span"),h=document.createElement("span");c.appendChild(document.createTextNode(a.display)),null!==a.module?(h.appendChild(document.createTextNode(a.module)),h.classList.add("module")):h.appendChild(document.createTextNode("(package)")),l.appendChild(c),l.appendChild(h),l.setAttribute("href",a.uri),u.appendChild(l),n.push(u)}(t=this.list).replaceChildren.apply(t,n),this.output.highlight(this.list)}else this.list.replaceChildren()}else this.pending=e},e.prototype.navigate=function(e){if(void 0!==this.output)switch(e.key){case"ArrowUp":this.output.index>0&&(this.output.rehighlight(this.list,this.output.index-1),e.preventDefault());break;case"ArrowDown":this.output.index<this.output.choices.length-1&&(this.output.rehighlight(this.list,this.output.index+1),e.preventDefault())}},e.prototype.follow=function(e){if(e.preventDefault(),void 0!==this.output&&void 0!==this.runner){var t=this.output.choices[this.output.index];window.location.assign(this.runner.symbols[parseInt(t.ref)].uri)}},e}();t.Searchbar=o}},t={};function r(n){var i=t[n];if(void 0!==i)return i.exports;var s=t[n]={exports:{}};return e[n].call(s.exports,s,s.exports,r),s.exports}(()=>{"use strict";var e=r(223);var t,n=document.getElementById("login"),i=document.getElementById("search-results");if(null!==i){var s=new e.Searchbar({list:i}),o=document.getElementById("search-input");null!==o&&(o.addEventListener("focus",(function(e){return s.focus()})),o.addEventListener("mousedown",(function(e){o.setAttribute("placeholder","search shortcut: /")})),o.addEventListener("blur",(function(e){o.setAttribute("placeholder","search symbols")})),o.addEventListener("input",(function(e){return s.suggest(e)})),o.addEventListener("keydown",(function(e){return s.navigate(e)})),document.addEventListener("keydown",(function(e){switch(e.key){case"Escape":document.activeElement===o&&o.blur();break;case"/":document.activeElement!==o&&(o.focus(),e.preventDefault())}})));var a=document.getElementById("search");null!==a&&a.addEventListener("submit",(function(e){return s.follow(e)}))}if(null!==n){var u=document.createElement("input"),l=(t=new Uint8Array(8),Array.from(window.crypto.getRandomValues(t),(function(e){return e.toString(16).padStart(2,"0")})).join(""));u.setAttribute("type","hidden"),u.setAttribute("name","state"),u.setAttribute("value",l),n.appendChild(u),document.cookie="login_state="+l+"; Path=/ ; SameSite=Lax"}})()})();
//# sourceMappingURL=Main.js.map