#This class responsibility is to manage the scope
DocUtils=require('./docUtils')

module.exports=class ScopeManager
	constructor:({@tags,@scopePath,@usedTags,@scopeList,@parser,@moduleManager,@nullGetter,@delimiters})->
		@moduleManager.scopeManager=this
	loopOver:(tag,callback,inverted=false)->
		value = @getValue(tag)
		@loopOverValue(value,callback,inverted)
	loopOverValue:(value,callback,inverted=false)->
		type = Object.prototype.toString.call(value)
		if inverted
			if !value? then return callback(@scopeList[@num])
			if !value then return callback(@scopeList[@num])
			if type=='[object Array]' && value.length == 0
				callback(@scopeList[@num])
			return

		if !value? then return
		if type == '[object Array]'
			for scope,i in value
				callback(scope)
		if type == '[object Object]'
			callback(value)
		if value == true
			callback(@scopeList[@num])
	getValue:(tag,@num=@scopeList.length-1)->
		scope=@scopeList[@num]
		try
			parser=@parser(tag)
			result=parser.get(scope)
		catch e
			result=null
		if !result? and @num>0 then return @getValue(tag,@num-1)
		result
	getValueFromScope: (tag) ->
		# search in the scopes (in reverse order) and keep the first defined value
		result = @getValue(tag)
		if result?
			if typeof result=='string'
				@useTag(tag,true)
				value= result
				if value.indexOf(@delimiters.start)!=-1 or value.indexOf(@delimiters.end)!=-1
					throw new Error("You can't enter #{@delimiters.start} or	#{@delimiters.end} inside the content of the variable. Tag: #{tag}, Value: #{result}")
			else if typeof result=="number"
				value=String(result)
			else value= result
		else
			@useTag(tag,false)
			value= @nullGetter(tag)
		value
	#set the tag as used, so that DocxGen can return the list of all tags
	useTag: (tag,val) ->
		if val
			u = @usedTags.def
		else
			u = @usedTags.undef
		for s,i in @scopePath
			u[s]={} unless u[s]?
			u = u[s]
		if tag!=""
			u[tag]= true
