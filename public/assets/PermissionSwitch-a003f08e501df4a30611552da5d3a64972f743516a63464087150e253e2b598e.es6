class PermissionSwitch {
  constructor(user, domElement) {
    this.user = user;
    this.id = domElement.data().id;
    this.switchtype = domElement.data().switchtype;
    this.attribute = domElement.data().attribute;
    this.inputDomElement = domElement.find('input');
    this.checked = this.inputDomElement.prop('checked');
    this.disabled = this.inputDomElement.prop('disabled');
    this.fullHistWarning = "WARNING: once you turn this on, it may be possible for your entire location history to be copied before you are able to turn it off again. Only share your history with highly trusted parties. Click OK to continue anyway."
  }

  changeDisableSwitches(state) {
    $(`div[data-id=${this.id}][data-switchtype=last_only].permission-switch`).find('input').prop("checked", false);
    $(`div[data-id=${this.id}].disable`).find('input').prop("disabled", state);
  }
}

class LocalSwitch extends PermissionSwitch {
  constructor(user, domElement, permissions, page) {
    super(user, domElement);
    this.permission = _.find(permissions, _.matchesProperty('id', this.id));
    this.attributeState = this.permission[this.attribute];
    this.page = page;
  }

  toggleSwitch() {
    if (this.switchtype === "disallowed") {
      const bool = (this.attributeState != 'disallowed')
    }
    if (this.switchtype === "complete" && this.checked) {
      let result = confirm(this.fullHistWarning);
      if(!result){
        $(`div[data-id=${this.id}][data-switchtype=${this.attributeState}].permission-switch`).find('input').prop("checked", true);
        return;
      }
    }
    this.permission[this.attribute] = this.nextState();
    $.ajax({
      url: `/users/${this.user}/devices/${this.permission['device_id']}/permissions/${this.id}`,
      type: 'PUT',
      dataType: 'script',
      data: { permission: this.permission, from: this.page }
    });
  }

  nextState() {
    if(this.attribute === "privilege") {
      return this.switchtype
    } else {
      return !this.attributeState
    }
  }
}

class MasterSwitch extends PermissionSwitch {
  constructor(user, domElement, permissions, idType, page) {
    super(user, domElement);
    this.permissions = permissions.filter(_.matchesProperty(idType, this.id));
    this.page = page;
  }

  toggleSwitch() {
    if (this.switchtype === "complete"){
      let result = confirm(this.fullHistWarning);
      if(!result){
        this.inputDomElement.prop("checked", !this.checked);
        return;
      }
    }
    this.permissions.forEach(function(permission) {
      const P_DOM_ELEMENT = $(`div[data-id=${permission.id}][data-switchtype=${this.switchtype}].permission-switch`);
      const P_SWITCH = new LocalSwitch(this.user, P_DOM_ELEMENT, this.permissions, this.page);
      if ((P_SWITCH.disabled && P_SWITCH.switchtype === 'last_only')){
        this.inputDomElement.prop("checked", false)
      } else if (this.checked !== P_SWITCH.checked) {
        P_SWITCH.toggleSwitch();
        P_SWITCH.checked = this.checked;
        P_SWITCH.inputDomElement.prop("checked", this.checked);
      }
    }, this);
  }

  setState() {
    const SWITCHES_CHECKED = [];

    this.permissions.forEach(function(permission){
      const P_DOM_ELEMENT = $(`div[data-id=${permission.id}][data-switchtype=${this.switchtype}].permission-switch`);
      SWITCHES_CHECKED.push(P_DOM_ELEMENT.find('input').prop("checked"))
    }, this)
    const NEW_MASTER_CHECKED_STATE = _.every(SWITCHES_CHECKED)
    this.inputDomElement.prop("checked", NEW_MASTER_CHECKED_STATE)
  }
}
