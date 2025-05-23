import fs from 'fs';
import path from 'path';
import {IDLBlob} from '../IDLBlob';
import {getTemplateKind, TemplateKind} from '../generateHeader';
import _ from 'lodash';
import {ClassObject, FunctionArguments, FunctionArgumentType, FunctionDeclaration, ParameterMode} from '../declaration';
import {GenerateOptions, generateSupportedOptions} from '../generator';
import {ParameterType} from '../analyzer';
import {getPointerType, isPointerType} from '../generateSource';
import { skipList } from './common';

function readHeaderTemplate(name: string) {
  return fs.readFileSync(path.join(__dirname, '../../../templates/idl_templates/plugin_api_templates/' + name + '.h.tpl'), {encoding: 'utf-8'});
}

function readSourceTemplate(name: string) {
  return fs.readFileSync(path.join(__dirname, '../../../templates/idl_templates/plugin_api_templates/' + name + '.cc.tpl'), {encoding: 'utf-8'});
}

function getClassName(blob: IDLBlob) {
  let raw = _.camelCase(blob.filename[11].toUpperCase() + blob.filename.slice(12));
  if (raw.slice(0, 3) == 'dom') {
    return 'DOM' + raw.slice(3);
  }
  if (raw.slice(0, 4) == 'html') {
    // Legacy support names.
    if (raw === 'htmlIframeElement') {
      return `HTMLIFrameElement`;
    }
    return 'HTML' + raw.slice(4);
  }
  if (raw.slice(0, 6) == 'svgSvg') {
    // special for SVGSVGElement
    return 'SVGSVG' + raw.slice(6)
  }
  if (raw.slice(0, 3) == 'svg') {
    return 'SVG' + raw.slice(3)
  }
  if (raw.slice(0, 3) == 'css') {
    return 'CSS' + raw.slice(3);
  }
  if (raw.slice(0, 2) == 'ui') {
    return 'UI' + raw.slice(2);
  }

  return `${raw[0].toUpperCase() + raw.slice(1)}`;
}

export function isStringType(type: ParameterType): boolean {
  return type.value === FunctionArgumentType.dom_string
    || type.value === FunctionArgumentType.legacy_dom_string;
}

export function isVoidType(type: ParameterType): boolean {
  return type.value === FunctionArgumentType.void;
}

export function isDoubleType(type: ParameterType): boolean {
  return type.value === FunctionArgumentType.double;
}
export function isIntType(type: ParameterType): boolean {
  return type.value === FunctionArgumentType.int32 || type.value === FunctionArgumentType.int64;
}
export function isVectorType(type: ParameterType): boolean {
  return !!(type.isArray && typeof type.value === 'object' && !Array.isArray(type.value));
}

function generatePublicReturnTypeValue(type: ParameterType, is32Bit: boolean = false, typeMode?: ParameterMode): string {
  if (typeMode?.dartImpl) {
    return 'NativeValue'
  }
  if (isPointerType(type)) {
    const pointerType = getPointerType(type);
    return `WebFValue<webf::${pointerType}, ${pointerType}PublicMethods>`;
  }
  if (isVectorType(type)) {
    return `VectorValueRef`;
  }
  switch (type.value) {
    case FunctionArgumentType.int64: {
      return 'int64_t';
    }
    case FunctionArgumentType.int32: {
      return 'int64_t';
    }
    case FunctionArgumentType.double: {
      return 'double';
    }
    case FunctionArgumentType.boolean: {
      return 'int32_t';
    }
    case FunctionArgumentType.dom_string:
    case FunctionArgumentType.legacy_dom_string: {
      return 'AtomicStringRef';
    }
    case FunctionArgumentType.any: {
      return 'NativeValue';
    }
    case FunctionArgumentType.void:
      return 'void';
    default:
      if (is32Bit) {
        return 'int64_t';
      }
      return 'void*';
  }
}

function generatePublicDictionaryFieldTypeValue(type: ParameterType, is32Bit: boolean = false): string {
  if (isPointerType(type)) {
    const pointerType = getPointerType(type);
    return `WebFValue<${pointerType}, ${pointerType}PublicMethods>`;
  }
  if (isVectorType(type)) {
    return `VectorValueRef`;
  }
  switch (type.value) {
    case FunctionArgumentType.int64: {
      return 'int64_t';
    }
    case FunctionArgumentType.int32: {
      return 'int64_t';
    }
    case FunctionArgumentType.double: {
      return 'double';
    }
    case FunctionArgumentType.boolean: {
      return 'int32_t';
    }
    case FunctionArgumentType.dom_string:
    case FunctionArgumentType.legacy_dom_string: {
      return 'const char*';
    }
    case FunctionArgumentType.any: {
      return 'NativeValue';
    }
    case FunctionArgumentType.void:
      return 'void';
    default:
      if (is32Bit) {
        return 'int64_t';
      }
      return 'void*';
  }
}

function generatePublicParameterType(type: ParameterType, is32Bit: boolean = false): string {
  if (isPointerType(type)) {
    const pointerType = getPointerType(type);
    // dictionary types
    if (pointerType.endsWith('Options') || pointerType.endsWith('Init')) {
      return `WebF${pointerType}*`;
    }
    // special case for EventListener
    else if (pointerType === 'JSEventListener') {
      return 'WebFEventListenerContext*';
    }
    return `${pointerType}*`;
  }
  if (isVectorType(type)) {
    return `VectorValueRef`;
  }
  switch (type.value) {
    case FunctionArgumentType.int64: {
      return 'int64_t';
    }
    case FunctionArgumentType.int32: {
      return 'int64_t';
    }
    case FunctionArgumentType.double: {
      return 'double';
    }
    case FunctionArgumentType.boolean: {
      return 'int32_t';
    }
    case FunctionArgumentType.any: {
      return 'NativeValue';
    }
    case FunctionArgumentType.dom_string:
    case FunctionArgumentType.legacy_dom_string: {
      return 'const char*';
    }
    default:
      if (is32Bit) {
        return 'int64_t';
      }
      return 'void*';
  }
}

function generateNativeValueConverter(type: ParameterType): string {

  if (isPointerType(type)) {
    return `Native_NewPtr<${getPointerType(type)}>`;
  }

  switch (type.value) {
    case FunctionArgumentType.int32:
    case FunctionArgumentType.int64:
      return `Native_NewInt64`;
    case FunctionArgumentType.double:
      return `Native_NewFloat64`;
    case FunctionArgumentType.boolean:
      return `Native_NewBool`;
    case FunctionArgumentType.dom_string:
    case FunctionArgumentType.legacy_dom_string:
      return `Native_NewCString`;
  }
  return ''
}

function generatePublicParametersType(parameters: FunctionArguments[], is32Bit: boolean = false): string {
  if (parameters.length === 0) {
    return '';
  }
  return parameters.map(param => {
    return `${generatePublicParameterType(param.type, is32Bit)}`;
  }).join(', ') + ', ';
}

function generatePublicParametersTypeWithName(parameters: FunctionArguments[], is32Bit: boolean = false): string {
  if (parameters.length === 0) {
    return '';
  }
  return parameters.map(param => {
    return `${generatePublicParameterType(param.type, is32Bit)} ${_.snakeCase(param.name)}`;
  }).join(', ') + ', ';
}

function generatePublicParametersName(parameters: FunctionArguments[]): string {
  if (parameters.length === 0) {
    return '';
  }
  return parameters.map(param => {
    const name = _.snakeCase(param.name);
    if (isPointerType(param.type)) {
      const pointerType = getPointerType(param.type);
      // dictionary types
      if (pointerType.endsWith('Options') || pointerType.endsWith('Init')) {
        return name + '_p';
      }
      // special case for EventListener
      else if (pointerType === 'JSEventListener') {
        return name + '_impl';
      }
      return name;
    }
    else if (isStringType(param.type)) {
      return name + '_atomic';
    }
    else if (isAnyType(param.type)) {
      return name + '_script_value';
    }
    return name;
  }).join(', ') + ', ';
}

export function isAnyType(type: ParameterType): boolean {
  return type.value === FunctionArgumentType.any;
}

export function getMethodsWithoutOverload(methods: FunctionDeclaration[]) {
  const methodsWithoutOverload = [] as (FunctionDeclaration | {rustName?: string})[];
  const methodsNames = new Set<string>();
  methods.forEach(method => {
    const name = method.name;
    if (methodsNames.has(name)) {
      const rustName = name + 'With' + method.args.map(arg => _.upperFirst(arg.name)).join('And');
      methodsWithoutOverload.push({
        ...method,
        rustName: rustName,
      })
    } else {
      methodsNames.add(name);
      methodsWithoutOverload.push(method);
    }
  });
  return methodsWithoutOverload;
}

function generatePluginAPIHeaderFile(blob: IDLBlob, options: GenerateOptions) {
  const baseTemplate = readHeaderTemplate('base');
  const contents = blob.objects.map(object => {
    const templateKind = getTemplateKind(object);
    if (templateKind === TemplateKind.null) {
      return '';
    }

    switch(templateKind) {
      case TemplateKind.Interface: {
        object = object as ClassObject;

        let dependentTypes = new Set<string>();

        object.props.forEach(prop => {
          if (isPointerType(prop.type)) {
            dependentTypes.add(getPointerType(prop.type));
          }
        });

        object.methods.forEach(method => {
          method.args.forEach(param => {
            if (isPointerType(param.type)) {
              dependentTypes.add(getPointerType(param.type));
            }
          });
          if (isPointerType(method.returnType)) {
            dependentTypes.add(getPointerType(method.returnType));
          }
          if (isVectorType(method.returnType)) {
            dependentTypes.add(getPointerType(method.returnType.value as ParameterType));
          }
        });

        const subClasses: string[] = [];

        function appendSubClasses(name: string) {
          ClassObject.globalClassRelationMap[name]?.forEach(subClass => {
            subClasses.push(subClass);
            appendSubClasses(subClass);
          });
        }

        if (object.name in ClassObject.globalClassRelationMap) {
          appendSubClasses(object.name);
        }

        const methodsWithoutOverload = getMethodsWithoutOverload(object.methods);
        return _.template(readHeaderTemplate('interface'))({
          className: getClassName(blob),
          parentClassName: object.parent,
          blob: blob,
          object,
          methodsWithoutOverload,
          generatePublicParameterType,
          generatePublicReturnTypeValue,
          generatePublicParametersType,
          generatePublicParametersTypeWithName,
          isStringType,
          generateNativeValueConverter,
          isIntType,
          isAnyType,
          isVectorType,
          dependentTypes: Array.from(dependentTypes),
          subClasses: _.uniq(subClasses),
          options,
          skipList,
        });
      }
      case TemplateKind.Dictionary: {
        object = object as ClassObject;

        let dependentTypes = new Set<string>();

        object.props.forEach(prop => {
          if (isPointerType(prop.type)) {
            dependentTypes.add(getPointerType(prop.type));
          }
        });
        const parentObjects = [] as ClassObject[];
        let node = object;

        while (node && node.parent) {
          const parentObject = ClassObject.globalClassMap[node.parent];
          if (parentObject) {
            parentObjects.push(parentObject);
            parentObject.props.forEach(prop => {
              if (isPointerType(prop.type)) {
                dependentTypes.add(getPointerType(prop.type));
              }
            });
          }
          node = parentObject;
        }

        return _.template(readHeaderTemplate('dictionary'))({
          className: getClassName(blob),
          parentClassName: object.parent,
          parentObjects,
          blob: blob,
          object,
          generatePublicDictionaryFieldTypeValue,
          isStringType,
          dependentTypes: Array.from(dependentTypes),
          options,
          skipList,
        });
      }
      case TemplateKind.globalFunction: {
        return '';
      }
    }
  });

  return _.template(baseTemplate)({
    content: contents.join('\n'),
    blob: blob
  }).split('\n').filter(str => {
    return str.trim().length > 0;
  }).join('\n') + '\n';
}

function generatePluginAPISourceFile(blob: IDLBlob, options: GenerateOptions) {
  const baseTemplate = readSourceTemplate('base');
  const contents = blob.objects.map(object => {
    const templateKind = getTemplateKind(object);
    if (templateKind === TemplateKind.null || templateKind === TemplateKind.Dictionary) {
      return '';
    }

    switch(templateKind) {
      case TemplateKind.Interface: {
        object = object as ClassObject;

        let dependentTypes = new Set<string>();

        object.props.forEach(prop => {
          if (isPointerType(prop.type)) {
            dependentTypes.add(getPointerType(prop.type));
          }
        });

        object.methods.forEach(method => {
          method.args.forEach(param => {
            if (isPointerType(param.type)) {
              dependentTypes.add(getPointerType(param.type));
            }
          });
          if (isPointerType(method.returnType)) {
            dependentTypes.add(getPointerType(method.returnType));
          }
        });

        object.construct?.args.forEach(param => {
          if (isPointerType(param.type)) {
            dependentTypes.add(getPointerType(param.type));
          }
        });

        const subClasses: string[] = [];

        function appendSubClasses(name: string) {
          ClassObject.globalClassRelationMap[name]?.forEach(subClass => {
            subClasses.push(subClass);
            appendSubClasses(subClass);
          });
        }

        if (object.name in ClassObject.globalClassRelationMap) {
          appendSubClasses(object.name);
        }

        const dependentClasses: {[key: string]: ClassObject} = [...dependentTypes].reduce((classes, type) => {
          classes[type] = ClassObject.globalClassMap[type];
          return classes;
        }, {} as {[key: string]: ClassObject});

        for (const key in dependentClasses) {
          if (key.endsWith('Options') || key.endsWith('Init')) {
            const parents = [] as ClassObject[]
            let node = dependentClasses[key];
            while(node && node.parent) {
              node = ClassObject.globalClassMap[node.parent];
              parents.push(node);
            }

            const parentsProps = parents.flatMap(object => object.props);
            dependentClasses[key].inheritedProps = parentsProps;
          }
        }

        const methodsWithoutOverload = getMethodsWithoutOverload(object.methods);
        return _.template(readSourceTemplate('interface'))({
          className: getClassName(blob),
          parentClassName: object.parent,
          blob: blob,
          object,
          methodsWithoutOverload,
          generatePublicReturnTypeValue,
          generatePublicParametersType,
          generatePublicParametersTypeWithName,
          generatePublicParametersName,
          generatePublicParameterType,
          isPointerType,
          getPointerType,
          isStringType,
          generateNativeValueConverter,
          isIntType,
          isAnyType,
          isVectorType,
          isVoidType,
          dependentTypes: Array.from(dependentTypes),
          dependentClasses,
          subClasses: _.uniq(subClasses),
          options,
          skipList,
        });
      }
      case TemplateKind.globalFunction: {
        return '';
      }
    }
  }).filter(str => str.trim().length > 0);

  if (contents.length === 0) {
    return '';
  }

  return _.template(baseTemplate)({
    content: contents.join('\n'),
    blob: blob
  }).split('\n').filter(str => {
    return str.trim().length > 0;
  }).join('\n') + '\n';
}

export function generatePluginAPI(blob: IDLBlob) {
  let options = generateSupportedOptions();

  const header = generatePluginAPIHeaderFile(blob, options);
  const source = generatePluginAPISourceFile(blob, options);

  return {
    header,
    source
  };
}
